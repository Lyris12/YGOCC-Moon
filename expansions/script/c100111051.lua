--created by Jake, coded by Lyris
--Emerald Veins Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)<1 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_DRAGON))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.PayLPCost(tp,Duel.GetLP(tp)//2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(5) and c:IsRace(RACE_DRAGON)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToChain() and tc:IsRelateToChain() and s.filter(tc) and tc:IsType(TYPE_NORMAL)) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)<1 or not Duel.SelectEffectYesNo(tp,c) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	e1:SetValue(-tc:GetLevel())
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2,true)
	local e3=e2:Clone()
	tc:RegisterEffect(e3,true)
	c:SetCardTarget(tc)
	c:CreateRelation(tc,RESET_EVENT+RESET_TURN_SET+RESET_TOFIELD+RESET_OVERLAY)
	tc:CreateRelation(c,RESET_EVENT+RESET_TURN_SET+RESET_TOFIELD+RESET_OVERLAY)
	local g=Group.FromCards(c,tc)
	g:KeepAlive()
	local e5=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetLabelObject(g)
	e4:SetOperation(s.leave)
	Duel.RegisterEffect(e4,tp)
end
function s.leave(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=eg&g
	if #tg==0 then return end
	local c=g:GetFirst()
	local tc=g:GetNext()
	if c:IsRelateToCard(tc) and tc:IsRelateToCard(c) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
	g:DeleteGroup()
	e:Reset()
end
