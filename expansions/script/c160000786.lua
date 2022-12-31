--Yuzu, Guardian of  Magnificent VINE
function c160000786.initial_effect(c)
	 --link summon
	aux.AddLinkProcedure(c,c160000786.matfilter,2)
	c:EnableReviveLimit() 
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(160000786,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c0)
	e1:SetCountLimit(1,160000786)
	e1:SetTarget(c160000786.target)
	e1:SetOperation(c160000786.activate)
	c:RegisterEffect(e1)
--cannot remove
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	c:RegisterEffect(e2)
	 --search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(160000786,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F+CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_DESTROYED)
	--e3:SetCountLimit(1,160000786)
	e3:SetCondition(c160000786.ohmycon)
	e3:SetTarget(c160000786.ohmytg)
	e3:SetOperation(c160000786.ohmyop)
	c:RegisterEffect(e3)
end
function c160000786.matfilter(c)
	return not c:IsLinkType(TYPE_TOKEN)
end
function c160000786.sfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end
function c160000786.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x285a)
end
function c160000786.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local gc=e:GetHandler():GetLinkedGroup():FilterCount(c160000786.drfilter,nil)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SetTargetPlayer(tp)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,gc)
end
function c160000786.activate(e,tp,eg,ep,ev,re,r,rp)
	local gc=e:GetHandler():GetLinkedGroup():FilterCount(c160000786.drfilter,nil)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(c160000786.sfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
	if g:IsExists(c160000786.sfilter,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
	Debug.Message(gc)
	if gc>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,gc,REASON_EFFECT)
	end
end
function c160000786.ohmycon(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()   return
e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and c:GetPreviousControler()==tp
end
function c160000786.ohmytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c160000786.filter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c160000786.xxfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x285a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c160000786.ohmyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c160000786.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c160000786.xxfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(6666,8)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=sg:Select(tp,1,1,nil)
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end