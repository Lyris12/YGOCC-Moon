--Dracosis Homecoming
function c39410.initial_effect(c)
	--effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39410,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39410.tg)
	e1:SetOperation(c39410.op)
	c:RegisterEffect(e1)
end
function c39410.cfilter(c,race)
	if race then
		return c:IsSetCard(0x300) and c:GetRace()&race~=0 and c:IsAbleToDeckOrExtraAsCost()
	else
		return c:IsSetCard(0x300) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
	end
end
function c39410.spfilter(c,e,tp)
	return c:IsSetCard(0x300) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c39410.thfilter(c)
	return c:IsSetCard(0x300) and c:IsSSetable()
end
function c39410.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then
		local sel=0
		if Duel.IsExistingMatchingCard(c39410.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c39410.cfilter),tp,LOCATION_GRAVE,0,1,nil,RACE_DRAGON) then
			sel=sel+1
		end
		if Duel.IsExistingMatchingCard(c39410.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c39410.cfilter),tp,LOCATION_GRAVE,0,1,nil,RACE_WYRM) then
			if c:IsLocation(LOCATION_SZONE) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
				sel=sel+2
			elseif c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 then
				sel=sel+2
			end
		end
		e:SetLabel(sel)
		return sel~=0 and Duel.IsExistingMatchingCard(c39410.cfilter,tp,LOCATION_HAND,0,1,nil)
	end
	local sel=e:GetLabel()
	if sel==3 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40044918,0))
		sel=Duel.SelectOption(tp,1152,1159)+1
	end
	if sel==1 then
		Duel.SelectOption(tp,1152)
	elseif sel==2 then
		Duel.SelectOption(tp,1159)
	end
	e:SetLabel(sel)
	if sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39410.cfilter),tp,LOCATION_GRAVE,0,1,1,nil,RACE_DRAGON)
		local gb=Duel.SelectMatchingCard(tp,c39410.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		g:AddCard(gb:GetFirst())
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
	end
	if sel==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39410.cfilter),tp,LOCATION_GRAVE,0,1,1,nil,RACE_WYRM)
		local gb=Duel.SelectMatchingCard(tp,c39410.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		g:AddCard(gb:GetFirst())
	end
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function c39410.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c39410.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif sel==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c39410.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SSet(tp,g)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
