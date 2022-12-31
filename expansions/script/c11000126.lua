--Void Viktor
function c11000126.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11000126,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,11000126)
	e1:SetTarget(c11000126.syntg)
	e1:SetOperation(c11000126.synop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11000126,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c11000126.thtg)
	e2:SetOperation(c11000126.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetRange(LOCATION_REMOVED)
	c:RegisterEffect(e3)	
end
function c11000126.filter1(c,e,tp)
	local lv=c:GetLevel()
	return c:IsSetCard(0x1F4) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(9) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.IsExistingMatchingCard(c11000126.filter2,tp,LOCATION_REMOVED,0,1,nil,tp,lv)
end
function c11000126.filter2(c,tp,lv)
	local rlv=lv-c:GetLevel()
	local rg=Duel.GetMatchingGroup(c11000126.filter3,tp,LOCATION_REMOVED,0,c)
	return rlv>0 and c:IsSetCard(0x1F4) and c:IsType(TYPE_TUNER) and c:IsAbleToDeck()
		and rg:CheckWithSumEqual(Card.GetLevel,rlv,1,2)
end
function c11000126.filter3(c)
	return c:IsSetCard(0x1F4) and c:GetLevel()>0 and not c:IsType(TYPE_TUNER) and c:IsAbleToDeck()
end
function c11000126.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c11000126.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c11000126.synop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,c11000126.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g1:GetFirst()
	if tc then
		local lv=tc:GetLevel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g2=Duel.SelectMatchingCard(tp,c11000126.filter2,tp,LOCATION_REMOVED,0,1,1,nil,tp,lv)
		local rlv=lv-g2:GetFirst():GetLevel()
		local rg=Duel.GetMatchingGroup(c11000126.filter3,tp,LOCATION_REMOVED,0,g2:GetFirst())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g3=rg:SelectWithSumEqual(tp,Card.GetLevel,rlv,1,2)
		g2:Merge(g3)
		Duel.SendtoDeck(g2,nil,0,REASON_EFFECT)
		Duel.SpecialSummonStep(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
--		local e1=Effect.CreateEffect(e:GetHandler())
--		e1:SetType(EFFECT_TYPE_SINGLE)
--		e1:SetCode(EFFECT_DISABLE)
--		e1:SetReset(RESET_EVENT+0x1fe0000)
--		tc:RegisterEffect(e1,true)
--		local e2=Effect.CreateEffect(e:GetHandler())
--		e2:SetType(EFFECT_TYPE_SINGLE)
--		e2:SetCode(EFFECT_DISABLE_EFFECT)
--		e2:SetReset(RESET_EVENT+0x1fe0000)
--		tc:RegisterEffect(e2,true)
--		tc:CompleteProcedure()
		Duel.SpecialSummonComplete()
		Duel.BreakEffect()
		Duel.ShuffleDeck(tp)
	end
end
function c11000126.tdfilter(c)
	return (c:IsSetCard(0x1F4) and not c:IsCode(11000126)) and c:IsAbleToRemove()
end
function c11000126.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11000126.tdfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToHand() 
		and Duel.IsExistingTarget(c11000126.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c11000126.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c11000126.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local c=e:GetHandler()
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
	if ct==2 and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
