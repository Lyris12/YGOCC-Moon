--Proxima Synchron
--Script by XGlitchy30
function c63553467.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--tuner fix
	local tuner=Effect.CreateEffect(c)
	tuner:SetType(EFFECT_TYPE_SINGLE)
	c:RegisterEffect(tuner)
	aux.EnablePandemoniumAttribute(c,tuner,true,TYPE_EFFECT+TYPE_TUNER)
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63553467,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,63553467)
	e1:SetCost(c63553467.setcost)
	e1:SetTarget(c63553467.settg)
	e1:SetOperation(c63553467.setop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,63553417)
	e2:SetCondition(c63553467.spcon)
	e2:SetCost(c63553467.spcost)
	e2:SetTarget(c63553467.sptg)
	e2:SetOperation(c63553467.spop)
	c:RegisterEffect(e2)
	--quick activation
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(c63553467.synchrocon)
	e3:SetOperation(c63553467.synchroop)
	c:RegisterEffect(e3)
end
--filters
function c63553467.setfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
end
function c63553467.spcheck(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsFaceup()
end
--tuner fix
function c63553467.tunerfix(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsType(TYPE_MONSTER)
end
--set
function c63553467.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c63553467.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.PandSSetCon(c63553467.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp)
		and Duel.IsExistingMatchingCard(c63553467.setfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function c63553467.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not aux.PandSSetCon(c63553467.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.PandSSetFilter(c63553467.setfilter),tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		aux.PandSSet(g,REASON_EFFECT,aux.GetOriginalPandemoniumType(g:GetFirst()))(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,g)
	end
end
--special summon
function c63553467.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c63553467.spcheck,tp,LOCATION_MZONE,0,1,nil)
end
function c63553467.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoDeck(g,nil,0,REASON_COST)
end
function c63553467.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c63553467.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x47e0000)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
--quick_activate
function c63553467.synchrocon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function c63553467.synchroop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_MZONE+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_SZONE+LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(c63553467.quickact)
	e1:SetCountLimit(1,63553427)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function c63553467.quickact(e,c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
end