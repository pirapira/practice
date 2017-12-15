Require Import FMapList.
Require Import BinNums.

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
      header: map nat PlasmaHeader;
      latest_block_number: nat;
      deposits: map nat (map nat unit);
    }.


Parameter StepResult : Type.
Parameter WithdrawSuccess : StepResult.

(* finite set of headers.  MSet or something else?  Just a finite map?  Just a list? *)

(* to be defined *)
Parameter submitBlockHeader : PlasmaHeader -> ManagerState -> ManagerState * StepResult.

(* to be defined *)
Parameter deposit : ManagerState -> ManagerState * StepResult.

Inductive StartWithdrawalInput :=
  swi: nat -> forall (idx : SixBits) (t : PlasmaTransaction),
      MerkleProof idx t -> StartWithdrawalInput.

(* to be defined *)
Parameter startWithdrawal : StartWithdrawalInput -> ManagerState -> ManagerState * StepResult.

Inductive ChallengeWithdrawalInput :=
  cwi: nat -> nat -> forall (idx : SixBits) (t : PlasmaTransaction),
           MerkleProof idx t -> ChallengeWithdrawalInput.

(* to be defined *)
Parameter challengeWithdrawal : ChallengeWithdrawalInput -> ManagerState -> ManagerState * StepResult.

(* to be defined, maybe needs some output. *)
Parameter finalizeWithdrawal : ManagerState -> ManagerState * StepResult.

(* to be defined *)
Parameter incrementTime : positive -> ManagerState -> ManagerState * StepResult.

(* XXX: how to model the 24-hour passage?  Maybe a special step for a tick of the clock? *)
Inductive step :=
  submitBlockHeaderStep : PlasmaHeader -> step
| depositStep : step
| startWithdrawalStep : StartWithdrawalInput -> step
| chllengeWithdrawalStep : ChallengeWithdrawalInput -> step
| finalizeWithdrawalStep : step
| timeStep : positive -> step
.

Definition applyStep (s : step) (orig : ManagerState) : ManagerState * StepResult :=
  match s with
  | submitBlockHeaderStep p => submitBlockHeader p orig
  | depositStep => deposit orig
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
      snd (applyStep (finalizeStep blknum txId tr m) one_day_after) = WithdrawSuccess.
Admitted.

(* Claim: a malicious operator that is capable of creating **invalid** blocks cannot withdraw any coins that they did not deposit. *)

(* how to express "they did not deposit? *)