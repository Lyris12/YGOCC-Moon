--Multitask Protocollo
--Script by XGlitchy30
function c86433612.initial_effect(c)
	c:SetUniqueOnField(1,0,86433612)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--double material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVAILABLE_LMULTIPLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
	e1:SetLabel(86433612)
	e1:SetTarget(c86433612.lkfilter)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_FIELD)
	e1x:SetCode(EFFECT_MULTIPLE_LMATERIAL)
	e1x:SetRange(LOCATION_SZONE)
	e1x:SetTargetRange(LOCATION_MZONE,0)
	e1x:SetTarget(c86433612.matfilter)
	e1x:SetLabel(86433612)
	e1x:SetValue(2)
	c:RegisterEffect(e1x)
	--extra link escape
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabel(10)
	e2:SetCondition(c86433612.extralink)
    e2:SetTargetRange(0,1)
    c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetLabel(11)
	e2x:SetTargetRange(1,0)
	c:RegisterEffect(e2x)
	--grant effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86433612,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,86433612)
	e3:SetCost(c86433612.effectcost)
	e3:SetTarget(c86433612.effecttg)
	e3:SetOperation(c86433612.effectop)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(86433612,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCountLimit(1,80433612)
	e4:SetCondition(c86433612.spcon)
	e4:SetTarget(c86433612.sptg)
	e4:SetOperation(c86433612.spop)
	c:RegisterEffect(e4)
end
c86433612.remembertype=0
--filters
function c86433612.filter(c)
	return ((c:IsLocation(LOCATION_EXTRA) and c:IsHasEffect(EFFECT_AVAILABLE_LMULTIPLE) and c:IsType(TYPE_LINK) and c:IsRace(RACE_CYBERSE))
		or (c:IsLocation(LOCATION_MZONE) and c:IsHasEffect(EFFECT_MULTIPLE_LMATERIAL) and c:IsFaceup() and c:IsSetCard(0x86f) and not c:IsType(TYPE_LINK)))
		and c:GetFlagEffect(86433612)<=0
end
function c86433612.lkfilter(e,c)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_CYBERSE)
end
function c86433612.matfilter(e,c)
	return c:IsFaceup() and c:IsSetCard(0x86f) and not c:IsType(TYPE_LINK)
end
function c86433612.checkEL(c,tp)
	return c:GetSequence()>6 and c:IsControler(tp)
end
function c86433612.cfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsType(TYPE_TOON+TYPE_SPIRIT+TYPE_UNION+TYPE_DUAL+TYPE_FLIP) or c:IsSetCard(0x86f)) and c:IsAbleToGraveAsCost()
end
function c86433612.spfilter(c,e,tp)
	return c:IsSetCard(0x86f) and c:IsType(TYPE_LINK) and c:GetLink()==2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
--extra link escape
function c86433612.extralink(e)
	local tp=e:GetHandlerPlayer()
	if e:GetLabel()==10 then
		return Duel.IsExistingMatchingCard(c86433612.checkEL,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,tp)
	elseif e:GetLabel()==11 then
		return Duel.IsExistingMatchingCard(c86433612.checkEL,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,1-tp)
	else
		return false
	end
end
--grants escape
function c86433612.effectcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c86433612.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c86433612.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,nil,REASON_COST)
		e:SetLabel(g:GetFirst():GetOriginalCode())
		c86433612.remembertype=g:GetFirst():GetType()&TYPE_TOON+TYPE_SPIRIT+TYPE_UNION+TYPE_DUAL+TYPE_FLIP
	end
end
function c86433612.effecttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c86433612.effectop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local val=e:GetLabel()
	local typ=c86433612.remembertype
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if val==0 then return end
		if typ~=0 then
			if typ==0 then return end
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
			e0:SetCode(EFFECT_ADD_TYPE)
			e0:SetValue(typ)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e0)
			c86433612.remembertype=0
		end
		local cid=tc:CopyEffect(val,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(86433612,2))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetLabel(cid)
		e1:SetOperation(c86433612.rstop)
		tc:RegisterEffect(e1)
	end
end
function c86433612.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
--special summon
function c86433612.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp and not c:IsLocation(LOCATION_DECK)
end
function c86433612.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	if chk==0 then return loc~=0 and Duel.IsExistingMatchingCard(c86433612.spfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function c86433612.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c86433612.spfilter),tp,loc,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end