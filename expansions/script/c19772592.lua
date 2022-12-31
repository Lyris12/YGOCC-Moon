--La Biblioteca degli AoJ - Cnolejia
--Script by XGlitchy30
function c19772592.initial_effect(c)
	c:EnableCounterPermit(0x197)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c19772592.activate)
	c:RegisterEffect(e1)
	--fusion/synchro summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19772592,1))
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,19772592)
	e2:SetCondition(c19772592.fscon)
	e2:SetTarget(c19772592.fstg)
	e2:SetOperation(c19772592.fsop)
	c:RegisterEffect(e2)
	--xyz summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19772592,2))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,11772592)
	e3:SetCondition(c19772592.xyzcon)
	e3:SetTarget(c19772592.xyztg)
	e3:SetOperation(c19772592.xyzop)
	c:RegisterEffect(e3)
	--pendulum summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19772592,3))
	e4:SetCategory(CATEGORY_COUNTER+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,12772592)
	e4:SetCondition(c19772592.plumcon)
	e4:SetTarget(c19772592.plumtg)
	e4:SetOperation(c19772592.plumop)
	c:RegisterEffect(e4)
	--link summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(19772592,4))
	e5:SetCategory(CATEGORY_COUNTER+CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,13772592)
	e5:SetCondition(c19772592.lkcon)
	e5:SetTarget(c19772592.lktg)
	e5:SetOperation(c19772592.lkop)
	c:RegisterEffect(e5)
	--special summon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(19772592,5))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCondition(c19772592.spcon)
	e6:SetCost(c19772592.spcost)
	e6:SetTarget(c19772592.sptg)
	e6:SetOperation(c19772592.spop)
	c:RegisterEffect(e6)
end
--filters
function c19772592.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x197) and c:IsAbleToHand()
		and not c:IsCode(19772592)
end
function c19772592.fsfilter(c,tp)
	return c:IsSetCard(0x197) and c:IsControler(tp) and (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SYNCHRO))
end
function c19772592.xyzfilter(c,tp)
	return c:IsSetCard(0x197) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
function c19772592.plumfilter(c,tp)
	return c:IsSetCard(0x197) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function c19772592.lkfilter(c,tp)
	return c:IsSetCard(0x197) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function c19772592.xyztarget(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(c19772592.matfilter,tp,LOCATION_HAND,0,1,nil)
end
function c19772592.matfilter(c)
	return c:IsSetCard(0x197) and c:IsType(TYPE_MONSTER)
end
function c19772592.tgfilter(c)
	return c:IsSetCard(0x197) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
function c19772592.spfilter(c,e,tp)
	return c:IsSetCard(0x197) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--Activate
function c19772592.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c19772592.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19772592,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
--fusion/synchro summon
function c19772592.fscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19772592.fsfilter,1,nil,tp)
end
function c19772592.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x197)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c19772592.fsop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x197,1)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATODECK)
		local tc=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
		if tc then
			if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
				Duel.ShuffleDeck(tp)
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
--xyz summon
function c19772592.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19772592.xyzfilter,1,nil,tp)
end
function c19772592.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19772592.xyztarget,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x197)
end
function c19772592.xyzop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	e:GetHandler():AddCounter(0x197,1)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c19772592.xyztarget,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mat=Duel.SelectMatchingCard(tp,c19772592.matfilter,tp,LOCATION_HAND,0,1,1,nil)
		if mat:GetCount()>0 then
			local mg=mat:GetFirst():GetOverlayGroup()
			if mg:GetCount()>0 then
				Duel.SendtoGrave(mg,REASON_RULE)
			end
			Duel.Overlay(tc,mat)
		end
	end
end
--pendulum summon
function c19772592.plumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19772592.plumfilter,1,nil,tp)
end
function c19772592.plumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x197)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_GRAVE)
end
function c19772592.plumop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x197,1)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
		if tc:GetCount()>0 then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
--pendulum summon
function c19772592.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19772592.lkfilter,1,nil,tp)
end
function c19772592.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19772592.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x197)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
function c19772592.lkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x197,1)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=Duel.SelectMatchingCard(tp,c19772592.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if tc:GetCount()>0 then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
--special summon
function c19772592.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function c19772592.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x197,4,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x197,4,REASON_COST)
end
function c19772592.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19772592.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c19772592.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19772592.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end