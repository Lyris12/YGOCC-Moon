--created by LeonDuvall, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil) end)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCost(cid.thcost)
	e2:SetTarget(cid.thtg)
	e2:SetOperation(cid.thop)
	c:RegisterEffect(e2)
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xcfd) and c:IsType(TYPE_TIMELEAP)
end
function cid.counterfilter(c)
	return c:IsSetCard(0xcfd) or c:GetSummonLocation()~=LOCATION_EXTRA
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xcfd) and c:IsLocation(LOCATION_EXTRA)
end
function cid.mfilter(c,tp,sc)
	return c:IsCanBeTimeleapMaterial(sc) and c:GetLevel()==sc:GetFuture()-1
		and Duel.GetLocationCountFromEx(tp,tp,c)>0
end
function cid.spfilter(c,e,tp)
	if not Duel.IsExistingMatchingCard(cid.mfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) or not c:IsSetCard(0xcfd)
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false) then return false end
	local et=global_card_effect_table[c]
	local res=false
	for _,e in ipairs(et) do
		if e:GetCode()==EFFECT_SPSUMMON_PROC then
			local ev=e:GetValue()
			local ec=e:GetCondition()
			if ev and (aux.GetValueType(ev)=="function" and ev(ef,c) or ev==SUMMON_TYPE_TIMELEAP) and (not ec or ec(e,c)) then res=true end
		end
	end
	return res
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_IGNORE_TIMELEAP_HOPT)
		ge1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		ge1:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
		ge1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TIMELEAP))
		Duel.RegisterEffect(ge1,0)
		local res=Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		ge1:Reset()
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetCode(EFFECT_IGNORE_TIMELEAP_HOPT)
	ge1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	ge1:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
	ge1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TIMELEAP))
	Duel.RegisterEffect(ge1,0)
	local g=Duel.GetMatchingGroup(cid.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		local tl=Duel.GetFlagEffect(tp,828)==0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON)
		e1:SetOperation(function() if tl then Duel.ResetFlagEffect(tp,828) end ge1:Reset() e1:Reset() end)
		Duel.RegisterEffect(e1,0)
		Duel.SpecialSummonRule(tp,sc)
	else ge1:Reset() end
end
function cid.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
