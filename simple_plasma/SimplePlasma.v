Require Import ssrbool ssreflect.

Require Import EqNat.
Require Import FMapList.
Require Import BinNums.
Require Import PArith.
Require Import Equalities.



(* Do I really want to do MerkleProof thing? *)

Parameter MerkleRoot : forall (Idx : Type) (Value : Type), Type.
Parameter merkleConstructor: forall {Idx Value : Type} (f : Idx -> Value), MerkleRoot Idx Value.

Parameter MerkleProof :
  forall {Idx Value : Type} (i : Idx) (v : Value), Type.
Parameter proofConstructor:
  forall {Idx Value : Type} (f : Idx -> Value) (i : Idx) (v : Value), f i = v -> MerkleProof i v.
Parameter merkleChecker : forall {Idx Value : Type} (i : Idx) (v : Value),
    MerkleRoot Idx Value -> MerkleProof i v -> bool.

Parameter merkleCheckerCorrectness :
  forall {Idx Value} i v (r : MerkleRoot Idx Value) p,
    merkleChecker i v r p = true ->
    forall f, merkleConstructor f = r -> f i = v.
(* Is this the only thing guaranteed? *)

(** MerkleRoot & MerkleProof should be a Module Type, maybe. *)

Module Type SimplePlasma (Address : HasEq).

Parameter SixBits : Type.
Parameter PlasmaTransaction : Type.

Record PlasmaHeader :=
  mkPlasmaHeader
    {
      block_number : nat;
      merkle_root : MerkleRoot SixBits PlasmaTransaction
    }.

Parameter map : Type -> Type -> Type.

Record ManagerState :=
  mkManagerState
    {
      headers: map nat PlasmaHeader;
      latest_block_number: nat;
      deposits: map nat (map nat unit);
      deposit_counter: nat; (* counter that starts at 64, reset when block number changes *)
      time: positive;
    }.

Parameter Address : Type.

Parameter StepResult : Type.
Parameter Failure : StepResult.
Parameter Success : StepResult.

(* finite set of headers.  MSet or something else?  Just a finite map?  Just a list? *)

(* to be defined *)
Parameter headers_update : ManagerState -> map nat PlasmaHeader -> ManagerState.

Parameter map_insert : forall {A B : Type}, A -> B -> (map A B) -> (map A B).

Parameter increment_latest_block_number : ManagerState -> ManagerState.

Definition submitBlockHeader (h : PlasmaHeader) (orig : ManagerState) : ManagerState * StepResult :=
  if beq_nat (h.(block_number)) (orig.(latest_block_number) + 1) then
    (increment_latest_block_number
       (headers_update orig (map_insert h.(block_number) h orig.(headers))), Success)
  else
    (orig, Failure).

Parameter increment_deposit_counter : ManagerState -> ManagerState.

Parameter add_deposit_from : Address -> ManagerState -> ManagerState.

Definition deposit (a : Address) (orig : ManagerState) : ManagerState * StepResult :=
  (increment_deposit_counter (add_deposit_from a orig), Success).

Inductive StartWithdrawalInput :=
  swi: nat -> forall (idx : SixBits) (t : PlasmaTransaction),
      MerkleProof idx t -> StartWithdrawalInput.

Parameter get_merkle_root : nat -> ManagerState -> MerkleRoot SixBits PlasmaTransaction.

Parameter checkAndRecordWithdrawal : StartWithdrawalInput -> ManagerState -> ManagerState * StepResult.

(* to be defined *)
Definition startWithdrawal (i : StartWithdrawalInput) (orig : ManagerState) : ManagerState * StepResult.
Proof.
case i.
move => blocknr idx t pr.
exact(
    if merkleChecker idx t (get_merkle_root blocknr orig) pr then
      checkAndRecordWithdrawal i orig
    else
      (orig, Failure)
  ).
Defined.

Inductive ChallengeWithdrawalInput :=
  cwi: nat -> nat -> forall (idx : SixBits) (t : PlasmaTransaction),
           MerkleProof idx t -> ChallengeWithdrawalInput.

(* to be defined *)
Parameter challengeWithdrawalOne : ChallengeWithdrawalInput -> ManagerState -> bool.
Parameter challengeWithdrawalTwo : ChallengeWithdrawalInput -> ManagerState -> bool.
(* to be defined... difficult... *)
Parameter challengeWithdrawalThree : ChallengeWithdrawalInput -> ManagerState -> bool.

Parameter noteChallenged : ChallengeWithdrawalInput -> ManagerState -> ManagerState.
Parameter noteChallengedThree : ChallengeWithdrawalInput -> ManagerState -> ManagerState.

Definition challengeWithdrawal (i : ChallengeWithdrawalInput) (orig : ManagerState) : ManagerState * StepResult :=
  if challengeWithdrawalThree i orig then
    (noteChallengedThree i orig, Success)
  else
  if challengeWithdrawalOne i orig || challengeWithdrawalTwo i orig then
    (noteChallenged i orig, Success)
  else
    (orig, Failure).

(* to be defined, maybe needs some output. *)
Parameter finalizeWithdrawal : ManagerState -> ManagerState * StepResult.

(* to be defined *)
Parameter updateTime : forall (orig : ManagerState) (v : positive), ManagerState.

(* to be defined *)
Definition incrementTime (d : positive) (orig : ManagerState) : ManagerState * StepResult :=
  (updateTime orig (orig.(time) + d), Success ).

(* XXX: how to model the 24-hour passage?  Maybe a special step for a tick of the clock? *)
Inductive step :=
  submitBlockHeaderStep : PlasmaHeader -> step
| depositStep : Address -> step
| startWithdrawalStep : StartWithdrawalInput -> step
| chllengeWithdrawalStep : ChallengeWithdrawalInput -> step
| finalizeWithdrawalStep : step
| timeStep : positive -> step
.

Definition applyStep (s : step) (orig : ManagerState) : ManagerState * StepResult :=
  match s with
  | submitBlockHeaderStep p => submitBlockHeader p orig
  | depositStep addr => deposit addr orig
  | startWithdrawalStep i => startWithdrawal i orig
  | chllengeWithdrawalStep i => challengeWithdrawal i orig
  | finalizeWithdrawalStep => finalizeWithdrawal orig
  | timeStep n => incrementTime n orig
  end.

(* repeat *)
Parameter applySteps : list step -> ManagerState -> ManagerState.

(* ... *)

(* Claim: if a transaction is confirmed, then the client will be able to withdraw the coin. *)

(* TODO: document arguments *)
Parameter TransactionIsConfirmed :
  forall (blknum : nat) (txId : SixBits), PlasmaTransaction -> ManagerState -> Prop.

Parameter withdrawalStep :
  forall (blknum : nat) (txId : SixBits), PlasmaTransaction -> ManagerState -> step.

(* add more inputs when necessary *)
(* TODO: document arguments *)
Parameter finalizeStep :
  forall (blknum : nat) (txId : SixBits), PlasmaTransaction -> ManagerState -> step.

Parameter one_day_passed : ManagerState -> ManagerState -> Prop.

(* If a ManagerState satisfies something,  (TransactionIsConfirmed)
 * player can call something  (withdrawalStep)
 * after the adversary does anything
 * 24 hours pass
 * player can finalize the thing.
 *)

Lemma WithdrawConfirmed :
  forall (m : ManagerState) blknum txId tr,
    TransactionIsConfirmed blknum txId tr m ->
    forall adv : list step,
      let one_day_after := applySteps (withdrawalStep blknum txId tr m :: adv) m in
      one_day_passed m one_day_after ->
      snd (applyStep (finalizeStep blknum txId tr m) one_day_after) = Success.
Admitted.

(* Claim: a malicious operator that is capable of creating **invalid** blocks cannot withdraw any coins that they did not deposit. *)
(* It has to be rewritten into something else. *)
(* XXX: this claim needs to assume enough people challenge the claim. *)

Parameter Coin : Type.

(* The coin is owned. *)
Parameter owns : Address -> Coin -> list step -> bool.

Parameter withdrawable : Address -> Coin -> list step -> bool.

(* Well, this prooperty does not hold because transactions can move around deposits *)
Lemma Nonstealable :
  forall a c history,
    withdrawable a c history -> owns a c history.

(* how to express "they did not deposit? *)
