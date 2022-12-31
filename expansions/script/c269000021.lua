--Ninjitsu Art of Refined Super Transformation
function c269000021.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c269000021.target)
	e1:SetOperation(c269000021.operation)
	c:RegisterEffect(e1)
	--to grave
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c269000021.tgop)
	c:RegisterEffect(e2)
	--act in hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(c269000021.handcon)
	c:RegisterEffect(e3)
end
function c269000021.filter1(c,tp,slv)
	local lv1=0
	if c:IsLevelAbove(1) then lv1=c:GetLevel()
		elseif c:GetRank() > 0 then lv1=c:GetRank()
		elseif c:GetLink() > 0 then lv1=c:GetLink()
	end
	return c:IsFaceup() and c:IsSetCard(0x2b) and lv1>0
		and Duel.IsExistingTarget(c269000021.filter2,tp,0,LOCATION_MZONE,1,nil,lv1,slv)
end
function c269000021.filter2(c,lv1,slv)
	local lv2=0
	if c:IsLevelAbove(1) then lv2=c:GetLevel()
		elseif c:GetRank() > 0 then lv2=c:GetRank()
		elseif c:GetLink() > 0 then lv2=c:GetLink()
	end
	return c:IsFaceup() and lv2>0 and lv1+lv2>=slv
end
function c269000021.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not lv or c:IsLevelBelow(lv))
end
function c269000021.lmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b) and c:IsLevelAbove(7)
end
function c269000021.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local sg=Duel.GetMatchingGroup(c269000021.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		if sg:GetCount()==0 then return false end
		local mg,mlv=sg:GetMinGroup(Card.GetLevel)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			and Duel.IsExistingTarget(c269000021.filter1,tp,LOCATION_MZONE,0,1,nil,tp,mlv)
	end
	local mg,mlv=sg:GetMinGroup(Card.GetLevel)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectTarget(tp,c269000021.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp,mlv)
	local tc=g1:GetFirst()
	local lv=0
	if tc:IsLevelAbove(1) then lv=tc:GetLevel()
		elseif tc:GetRank() > 0 then lv=tc:GetRank()
		elseif tc:GetLink() > 0 then lv=tc:GetLink()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectTarget(tp,c269000021.filter2,tp,0,LOCATION_MZONE,1,1,nil,lv,mlv)
	g1:Merge(g2)
	if Duel.IsExistingMatchingCard(c269000021.lmfilter,tp,LOCATION_MZONE,0,1,nil) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(c269000021.chainlm)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
function c269000021.chainlm(e,rp,tp)
	return tp==rp
end
function c269000021.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==0 then return end
	Duel.SendtoGrave(tg,REASON_EFFECT)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=tg:GetFirst()
	local lv=0
	if tc:IsLocation(LOCATION_GRAVE) then
		if tc:IsLevelAbove(1) then lv=tc:GetLevel()
			elseif tc:GetRank() > 0 then lv=tc:GetRank()
			elseif tc:GetLink() > 0 then lv=tc:GetLink()
		end
	end
	tc=tg:GetNext()
	if tc and tc:IsLocation(LOCATION_GRAVE) then
		if tc:IsLevelAbove(1) then lv=lv+tc:GetLevel()
			elseif tc:GetRank() > 0 then lv=lv+tc:GetRank()
			elseif tc:GetLink() > 0 then lv=lv+tc:GetLink()
		end
	end
	if lv==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c269000021.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		Duel.BreakEffect()
		c:SetCardTarget(tc)
	end
	Duel.SpecialSummonComplete()
end
function c269000021.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.SendToGrave(tc,REASON_EFFECT)
	end
end
function c269000021.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x2B)
end
function c269000021.handcon(e)
	return not Duel.IsExistingMatchingCard(c269000021.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end