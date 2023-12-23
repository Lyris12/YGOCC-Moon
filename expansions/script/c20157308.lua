--Origin Dragon Face Off
--created by Ace, coded by Lyris

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:HOPT(true)
	e1:SetRelevantTimings(TIMING_DAMAGE_STEP)
	e1:SetCondition(function() return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated() end)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--add to hand
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.tdcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DRAGON)
end
function s.rmfilter(c,tp,val)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and c:IsAttackBelow(val)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		return #g>0 and mg:IsExists(aux.nzatk,1,nil)
	end
	local val=mg:GetSum(Card.GetAttack)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,1-tp,LOCATION_MZONE,-val)
	local sg=g:Filter(s.rmfilter,nil,tp,val)
	if #sg>0 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,1-tp,LOCATION_MZONE)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if #g<=0 or #mg<=0 then return end
	local val=mg:GetSum(Card.GetAttack)*-1
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local preatk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		if tc:RegisterEffect(e1) and preatk~=0 and tc:IsAttack(0) and not tc:IsImmuneToEffect(e1) then
			dg:AddCard(tc)
		end
	end
	Duel.AdjustAll()
	local rg=dg:Filter(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)
	if #rg>0 then
		Duel.BreakEffect()
		Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
	end
end

function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(REASON_COST,tp,Card.IsCode,3,nil,TOKEN_DRAGON_EGG) end
	local g=Duel.SelectReleaseGroup(REASON_COST,tp,Card.IsCode,3,3,nil,TOKEN_DRAGON_EGG)
	Duel.Release(g,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetCardOperationInfo(e:GetHandler(),CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
