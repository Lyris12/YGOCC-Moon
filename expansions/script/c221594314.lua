--created by Walrus, coded by XGlitchy30
--Voidictator Demon - Guardian of Corvus
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.RitualSummonedCond)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(aux.BattlePhaseCond())
	e3:SetValue(s.actlmtval)
	c:RegisterEffect(e3)
end
function s.rmfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.Group(s.rmfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,1-tp,LOCATION_MZONE)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,e:GetHandler(),1,tp,LOCATION_MZONE,#g*800)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.rmfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local c=e:GetHandler()
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsFaceup() and c:IsRelateToChain() then
			local ct=Duel.GetOperatedGroup():FilterCount(aux.BecauseOfThisEffect(e),nil)
			if ct>0 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
				e1:SetValue(ct*800)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				c:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
				c:RegisterEffect(e2)
			end
		end
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.cfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	local rg=g:RandomSelect(tp,1)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Search(c,tp)
	end
end
function s.actlmtval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsSummonType(SUMMON_TYPE_SPECIAL) and re:IsActiveType(TYPE_MONSTER)
end
