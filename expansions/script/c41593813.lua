--created by LeonDuvall, coded by Lyris
--Skypiercer Air Superiority
local s,id,o=GetID()
function s.initial_effect(c)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.ctfilter)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetCondition(s.drcon)
	e2:SetCost(aux.AND(s.cost,aux.bfgcost))
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
function s.ctfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_MACHINE)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)<1 end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(s.ctfilter)))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x3bb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.dfilter(c)
	return s.cfilter(c) and c:IsType(TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE)<1 or Duel.IsEnvironment(41593810,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local b2=Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_MZONE,0,1,nil) and #g>0
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,{b1,1152},{b2,1124})
	if op<2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.ssummon)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetOperation(s.destroy)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
function s.ssummon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
function s.destroy(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Select(tp,1,1,nil)
	Duel.HintSelection(g)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3bb)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
