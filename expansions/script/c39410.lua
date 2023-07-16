--Dracosis Homecoming

local s,id=GetID()
function s.initial_effect(c)
	--effect
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCost(aux.DummyCost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function s.gcheck(g,races)
	return g:GetClassCount(Card.GetLocation)==2 and g:IsExists(Card.IsRace,1,nil,races)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x300) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c)
	return c:IsSetCard(0x300) and c:IsSSetable()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local races=0
	local b1=(Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp))
	local b2=Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if b1 then races=RACE_DRAGON end
	if b2 then races=races|RACE_WYRM end
	local g=Duel.Group(s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil)
	if chk==0 then
		return races~=0 and e:IsCostChecked() and g:CheckSubGroup(s.gcheck,2,2,races)
	end
	local rchk=0
	Duel.HintMessage(tp,HINTMSG_TODECK)
	local tg=g:SelectSubGroup(tp,s.gcheck,false,2,2,races)
	if #tg>0 then
		if tg:IsExists(Card.IsRace,1,nil,RACE_DRAGON) then rchk=RACE_DRAGON end
		if tg:IsExists(Card.IsRace,1,nil,RACE_WYRM) then rchk=rchk|RACE_WYRM end
		local hg,gg=tg:Filter(Card.IsLocation,nil,LOCATION_HAND),tg:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_HAND)
		if #hg>0 then
			Duel.ConfirmCards(1-tp,hg)
		end
		if #gg>0 then
			Duel.HintSelection(gg)
		end
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
	local sel=aux.Option(tp,false,false,{b1 and rchk&RACE_DRAGON>0,STRING_SPECIAL_SUMMON},{b2 and rchk&RACE_WYRM>0,STRING_SET})
	if not sel then return end
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
	elseif sel==1 then
		e:SetCategory(0)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==0 then
		if Duel.GetMZoneCount(tp)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	end
end
