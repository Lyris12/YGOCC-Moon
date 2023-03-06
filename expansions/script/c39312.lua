--Infinity Ranger

aux.RequireExternalScript("glitchylib_adjust_events")
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_GAINED_ATK)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(aux.EventGroupCond(aux.BuildFilter(Card.IsFaceup,{Card.IsLocation,LOCATION_MZONE})))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(aux.EventGroupCond(aux.BuildFilter(Card.IsFaceup,{Card.IsType,TYPE_TOKEN})))
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(aux.TRUE)
	c:RegisterEffect(e3)
	--gain atk
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+100)
	e4:SetHintTiming(TIMING_DAMAGE_STEP,RELEVANT_TIMINGS|TIMING_DAMAGE_STEP)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetMZoneCount(tp)>0 and c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) and aux.ExceptOnDamageCalc()
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x24f)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,g:GetFirst():GetControler(),g:GetFirst():GetLocation(),500)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
