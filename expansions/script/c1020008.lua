--[[
Machina-Eyes Zero
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--fusion material
	aux.AddFusionProcCode2(c,1020001,1020007,true,true)
	aux.AddContactFusionProcedureGlitchy(c,0,false,0,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST|REASON_MATERIAL)
	--control only one
	c:SetUniqueOnField(1,0,id)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--cannot target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--indes
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	--chain attack
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,1)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(aux.bdocon)
	e4:SetCost(s.atcost)
	e4:SetTarget(s.attg)
	e4:SetOperation(s.atop)
	c:RegisterEffect(e4)
end
--E1
function s.val(e)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,aux.NOT(Card.IsCode)),0,LOCATION_MZONE,LOCATION_MZONE,nil,id)
	if #g==0 then return 0 end
	local _,base=g:GetMaxGroup(Card.GetAttack)
	local _,atk=g:GetMinGroup(Card.GetAttack)
	return base-atk
end

--E2
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD,nil)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=e:GetHandler():GetBattleTarget()
	local a=tc:IsMonster() and tc:IsLocation(LOCATION_GB) and tc:IsFaceupEx() and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)
	local b=Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp,POS_FACEDOWN)
	if chk==0 then return a or b end
	local op=aux.Option(tp,id,2,a,b)
	Duel.SetTargetParam(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
		e:SetProperty(0)
		Duel.SetTargetCard(tc)
		Duel.SetCardOperationInfo(tc,CATEGORY_SPECIAL_SUMMON)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,1-tp,LOCATION_MZONE,-1000)
	elseif op==1 then
		e:SetCategory(CATEGORY_REMOVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp,POS_FACEDOWN)
		Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
	end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	local op=Duel.GetTargetParam()
	if op==0 then
		if Duel.SpecialSummonATK(e,tc,0,tp,1-tp,false,false,POS_FACEUP_ATTACK,nil,-1000) and c:IsRelateToChain() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(c:GetAttackAnnouncedCount())
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
			c:RegisterEffect(e1)
		end
	elseif op==1 then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end