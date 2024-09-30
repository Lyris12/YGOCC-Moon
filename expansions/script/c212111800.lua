--created by Slick, coded by Lyris
--Kronologistics Jumpdrive
local s,id,o = GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddCodeList(c,212111811)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ENGAGE)
	e1:HOPT()
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.eucon)
	e1:SetTarget(s.eutg)
	e1:SetOperation(s.euop)
	c:RegisterEffect(e1)
	c:DriveEffect(-4,1131,CATEGORY_NEGATE,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DAMAGE_STEP,EVENT_CHAINING,s.negcon,nil,s.negtg,s.negop)
	c:DriveEffect(-4,1159,nil,EFFECT_TYPE_IGNITION,0,nil,nil,nil,s.settg,s.setop)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:HOPT()
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.eucon(e,tp)
	return Duel.IsEnvironment(212111811,tp)
end
function s.eutg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return e:GetHandler():IsCanUpdateEnergy(2,tp,REASON_EFFECT,e) end
end
function s.euop(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then c:UpdateEnergy(2,tp,REASON_EFFECT,RESET_EVENT+RESETS_STANDARD,c,e) end
end
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x44a)
end
function s.negcon(e,tp,_,_,ev,re,_,rp)
	if rp~=1-tp or not (re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if g and g:IsExists(s.cfilter,1,nil,tp) then return true end
	end
	return ex and tg and tg:FilterCount(s.cfilter,nil,tp)==1 and tc+1-#tg>0
end
function s.negtg(e,tp,eg,_,_,_,_,_,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(_,_,_,_,ev)
	Duel.NegateActivation(ev)
end
function s.filter(c)
	return c:IsSSetable() and (c:IsCode(212111811) or aux.IsCodeListed(c,212111811) and c:IsType(TYPE_SPELL))
end
function s.settg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	Duel.SSet(tp,Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil))
end
function s.sfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsSetCard(0x44a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.alim)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
function s.alim(e,te)
	return te:IsActiveType(TYPE_MONSTER) and not te:IsActiveType(TYPE_EXTRA+TYPE_DRIVE)
end
function s.tdtg(e,tp,_,_,_,_,_,_,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp)
		and (c:IsSummonType(SUMMON_TYPE_DRIVE) or c:IsType(TYPE_SPELL)) end
	if chk==0 then return Duel.IsExistingTarget(c:IsSummonType(SUMMON_TYPE_DRIVE) or Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_SPELL) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c:IsSummonType(SUMMON_TYPE_DRIVE) or Card.IsType,tp,0,LOCATION_GRAVE,1,3,nil,TYPE_SPELL)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop()
	Duel.SendtoDeck(Duel.GetTargetsRelateToChain(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
