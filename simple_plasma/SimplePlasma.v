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

(* finite set of headers.  MSet or something else?  Just a finite map?  Just a list? *)

(* to be defined *)
Parameter submitBlockHeader : PlasmaHeader -> ManagerState -> ManagerState.

(* to be defined *)
Parameter deposit : ManagerState -> ManagerState.

Inductive StartWithdrawalInput :=
  swi: nat -> forall (idx : SixBits) (t : PlasmaTransaction),
      MerkleProof idx t -> StartWithdrawalInput.

(* to be defined *)
Parameter startWithdrawal : StartWithdrawalInput -> ManagerState -> ManagerState.

Inductive ChallengeWithdrawalInput :=
  cwi: nat -> nat -> forall (idx : SixBits) (t : PlasmaTransaction),
           MerkleProof idx t -> ChallengeWithdrawalInput.

(* to be defined *)
Parameter challengeWithdrawal : ChallengeWithdrawalInput -> ManagerState -> ManagerState.

(* to be defined, maybe needs some output. *)
Parameter finalizeWithdrawal : ManagerState -> ManagerState.

(* to be defined *)
Parameter incrementTime : positive -> ManagerState -> ManagerState.

(* XXX: how to model the 24-hour passage?  Maybe a special step for a tick of the clock? *)
Inductive step :=
  submitBlockHeaderStep : PlasmaHeader -> step
| depositStep : step
| startWithdrawalStep : StartWithdrawalInput -> step
| chllengeWithdrawalStep : ChallengeWithdrawalInput -> step
| finalizeWithdrawalStep : step
| timeStep : positive -> step
.

Definition applyStep (s : step) (orig : ManagerState) : ManagerState :=
  match s with
  | submitBlockHeaderStep p => submitBlockHeader p orig
  | depositStep => deposit orig
  | startWithdrawalStep i => startWithdrawal i orig
  | chllengeWithdrawalStep i => challengeWithdrawal i orig
  | finalizeWithdrawalStep => finalizeWithdrawal orig
  | timeStep n => incrementTime n orig
  end.

(* ... *)

(* Claim: if a transaction is confirmed, then the client will be able to withdraw the coin. *)

Parameter TransactionIsConfirmed :
  forall (blknum : nat) (txId : SixBits), PlasmaTransaction -> ManagerState -> Prop.

Definition withdrawalStep :
  forall (blknum : nat) (txId : SixBits), PlasmaTransaction -> ManagerState -> step.

(* add more inputs when necessary *)
Definition finalizeStep :
  forall (blknum : nat) (txId : SixBits), PlasmaTransaction -> ManagerState -> step.

(* If a ManagerState satisfies something,  (TransactionIsConfirmed)
 * player can call something  (withdrawalStep)
 * after the adversary does anything
 * 24 hours pass
 * player can finalize the thing.
 *)


(* Claim: a malicious operator that is capable of creating **invalid** blocks cannot withdraw any coins that they did not deposit. *)
