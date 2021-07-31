--Machina-Eyes Zero
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	aux.AddFusionProcCode2(c,1020001,1020007,true,true)
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	c:EnableReviveLimit()
	--change name
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e:SetCode(EFFECT_ADD_SETCODE)
	e:SetValue(0x3ded)
	c:RegisterEffect(e)
	--atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
	--cannot target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--indes
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
	--chain attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65676461,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.atcon)
	e1:SetCost(s.atcost)
	e1:SetTarget(s.attg)
	c:RegisterEffect(e1)
end
function s.val(e)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,aux.NOT(Card.IsCode)),0,LOCATION_MZONE,LOCATION_MZONE,nil,id)
	if #g==0 then return 0 end
	local _,base=g:GetMaxGroup(Card.GetAttack)
	local _,atk=g:GetMinGroup(Card.GetAttack)
	return base-atk
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c==Duel.GetAttacker() and c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local a=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.GetAttackTarget():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	local b=Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp,POS_FACEDOWN)
	if chk==0 then return a or b end
	if a and b then op=Duel.SelectOption(tp,1075,1192) else op=(a and 0) or 1 end
	if op==0 then
		e:SetOperation(s.atop1)
		Duel.GetAttackTarget():CreateEffectRelation(e)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,Duel.GetAttackTarget(),1,0,0)
	else
		e:SetOperation(s.atop2)
		e:SetOperation(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp,POS_FACEDOWN)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
function s.atop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=Duel.GetAttackTarget()
	if not bc:IsRelateToEffect(e) then return end
	if Duel.SpecialSummonStep(bc,0,tp,1-tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(bc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			Duel.ChainAttack(bc)
		end
	end
end
function s.atop2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
