--created by Walrus, coded by XGlitchy30
--Voidictator Rune - Void Overrule
local s,id=GetID()
function s.initial_effect(c)
	if not aux.EnableSpSummonRitualMonsterOperationInfo then
		aux.EnableSpSummonRitualMonsterOperationInfo=true
	end
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:HOPT()
	e1:SetFunctions(s.condition,aux.BanishCost(aux.ArchetypeFilter(ARCHE_VOIDICTATOR),LOCATION_HAND|LOCATION_GRAVE,0,3),s.target,s.activate)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:Desc(2)
	e1x:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
	e1x:SetType(EFFECT_TYPE_ACTIVATE)
	e1x:SetCode(EVENT_CHAINING)
	e1x:SHOPT()
	e1x:SetFunctions(s.condition2,aux.BanishCost(aux.ArchetypeFilter(ARCHE_VOIDICTATOR),LOCATION_HAND|LOCATION_GRAVE,0,3),s.target2,s.activate2)
	c:RegisterEffect(e1x)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SHOPT()
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
s.PreventWrongRedirect=false
function s.efilter(c,tp)
	return (c:IsSummonLocation(LOCATION_EXTRA) or (c:IsFaceup() and c:IsType(TYPE_RITUAL))) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and aux.NegateSummonCondition() and eg:IsExists(s.efilter,1,nil,tp) and Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_VOIDICTATOR),tp,LOCATION_MZONE,0,1,nil)
end
function s.chfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.efilter,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	if Duel.IsExists(false,s.chfilter,tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.efilter,nil,tp)
	if #g==0 then return end
	Duel.NegateSummon(g)
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
function s.checkfilter(c)
	return c:IsLocation(LOCATION_EXTRA) or c:IsType(TYPE_RITUAL)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==1-tp and Duel.IsChainNegatable(ev)) then return false end
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and (re:GetActiveType()&(TYPE_SPELL|TYPE_RITUAL)==TYPE_SPELL|TYPE_RITUAL or re:GetHandler():GetOriginalCode()==99426088) then return true end
	local ex,g,ct,p,loc=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	if ex and ((g and g:IsExists(s.checkfilter,1,nil)) or (ct>0 and loc==LOCATION_EXTRA) or (ct>1 and loc&LOCATION_EXTRA==LOCATION_EXTRA)) then
		return true
	end
	local tabtab=Duel.GetCustomOperationInfo(ev,CATEGORY_SPSUMMON_RITUAL_MONSTER)
	if type(tabtab)=="table" then
		for _,tab in ipairs(tabtab) do
			ex,g,ct,p,loc=table.unpack(tab)
			if ct>0 then
				return true
			end
		end
	end
	return false
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)
	end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,ARCHE_VOIDICTATOR_SERVANT) end
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,ARCHE_VOIDICTATOR_SERVANT)
	Duel.Release(g,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsSSetable() and Duel.SSet(tp,c)>0 and aux.SetSuccessfullyFilter(c) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_BANISH_REDIRECT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetCondition(function()
			return not s.PreventWrongRedirect
		end)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_LEAVE_FIELD_P)
		e2:SetCondition(function()
			return not s.PreventWrongRedirect
		end)
		e2:SetOperation(s.bfdop)
		e2:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e2,true)
	end
end
function s.bfdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	s.PreventWrongRedirect=true
	Duel.Remove(c,POS_FACEDOWN,c:GetReason()|REASON_REDIRECT)
	s.PreventWrongRedirect=false
end
