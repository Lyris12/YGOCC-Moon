--created by LeonDuvall, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xcfd) and c:IsType(TYPE_TIMELEAP)
end
function s.counterfilter(c)
	return c:IsSetCard(0xcfd) or c:GetSummonLocation()~=LOCATION_EXTRA
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xcfd) and c:IsLocation(LOCATION_EXTRA)
end
function s.mfilter(c,tp,sc)
	return c:IsCanBeTimeleapMaterial(sc) and c:GetLevel()==sc:GetFuture()-1
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.spfilter(c,e,tp)
	if not Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) or not c:IsSetCard(0xcfd)
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
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=Group.CreateGroup()
		for tc in aux.Next(Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_TIMELEAP)) do
			local ef=Effect.CreateEffect(c)
			ef:SetType(EFFECT_TYPE_SINGLE)
			ef:SetCode(EFFECT_IGNORE_TIMELEAP_HOPT)
			tc:RegisterEffect(ef)
			if s.spfilter(tc,e,tp) then g:AddCard(tc) end
			ef:Reset()
		end
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_TIMELEAP)
	for tc in aux.Next(mg) do
		local ef=Effect.CreateEffect(c)
		ef:SetType(EFFECT_TYPE_SINGLE)
		ef:SetCode(EFFECT_IGNORE_TIMELEAP_HOPT)
		ef:SetReset(RESET_EVENT+RESET_CONTROL)
		tc:RegisterEffect(ef)
	end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		mg:RemoveCard(sc)
		local tl=Duel.GetFlagEffect(tp,828)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON)
		e1:SetOperation(function(ef,p,tg) if tg:GetFirst()~=sc then return end if tl==0 then Duel.ResetFlagEffect(tp,828) end sc:ResetEffect(RESET_CONTROL,RESET_EVENT) e1:Reset() end)
		Duel.RegisterEffect(e1,tp)
		Duel.SpecialSummonRule(tp,sc)
		if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
	end
	for tc in aux.Next(mg) do tc:ResetEffect(RESET_CONTROL,RESET_EVENT) end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
