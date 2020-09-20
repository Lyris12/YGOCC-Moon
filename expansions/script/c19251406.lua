local m=19251406
local cm=_G["c"..m]
cm.name="灵知力场"
function cm.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(m,ACTIVITY_SPSUMMON,cm.counterfilter)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.atktg)
	e2:SetValue(cm.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,0))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e4:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PSYCHO))
	c:RegisterEffect(e4)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,m)
	e4:SetCost(cm.syncost)
	e4:SetTarget(cm.syntg)
	e4:SetOperation(cm.synop)
	c:RegisterEffect(e4)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(m,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cm.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or c:IsType(TYPE_SYNCHRO)
end
function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
function cm.atktg(e,c)
	return c:IsRace(RACE_PSYCHO)
end
function cm.atkfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsPosition(POS_FACEUP)
end
function cm.atkval(e,c)
	return Duel.GetMatchingGroupCount(cm.atkfilter,tp,LOCATION_REMOVED,0,nil)*100
end
function cm.syntunerfilter(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(cm.synnontunerfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function cm.synnontunerfilter(c,e,tp,tc)
	local tlv=tc:GetLevel()
	local ntlv=c:GetLevel()
	local lv=0
	if tlv>0 and ntlv>0 then
		lv=tlv+ntlv
	end
	return lv>0 and c:IsRace(RACE_PSYCHO) and not c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(cm.synexfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv)
end
function cm.synexfilter(c,e,tp,lv)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_PSYCHO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function cm.syncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.syntunerfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local g=Duel.SelectMatchingCard(tp,cm.syntunerfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tuner=g:GetFirst()
	g:Merge(Duel.SelectMatchingCard(tp,cm.synnontunerfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tuner))
	e:SetLabel(g:GetSum(Card.GetLevel))
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.syntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cm.synop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	if not Duel.IsExistingMatchingCard(cm.synexfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cm.synexfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
	if g then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end