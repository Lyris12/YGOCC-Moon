--created by LeonDuvall of Discord, coded by Lyris
--YC.Orgのパイロット・ストラターラムラム
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.trigger_con)
	e1:SetOperation(cid.trigger_op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetCountLimit(1,id)
	e3:SetTarget(cid.grave_tg)
	e3:SetOperation(cid.grave_op)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1,id+1000)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(cid.summon_op)
	c:RegisterEffect(e4)
	local e4=e4:Clone()
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_END_PHASE)
	e4:SetCost(cid.summon_cost)
	c:RegisterEffect(e4)
end
function cid.trigger_filter(c,tp,e)
	return (c==e:GetHandler() or (c:IsFaceup() and c:IsSetCard(0x195))) and c:IsControler(tp)
end
function cid.trigger_con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.trigger_filter,1,nil,tp,e)
end
function cid.trigger_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,0,0,0)
end
function cid.grave_filter(c)
	return c:IsSetCard(0x195,0x96b) and c:IsAbleToGrave()
end
function cid.grave_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.grave_filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function cid.grave_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(Duel.SelectMatchingCard(tp,cid.grave_filter,tp,LOCATION_DECK,0,1,1,nil),REASON_EFFECT)
end
function cid.summon_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function cid.summon_filter(c,e,tp)
	return c:IsSetCard(0x195,0x96b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.summon_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,cid.summon_filter,tp,LOCATION_HAND,0,0,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
