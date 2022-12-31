--Chaos Evolution
function c249000907.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c249000907.target)
	e1:SetOperation(c249000907.activate)
	c:RegisterEffect(e1)
end
function c249000907.tfilterm(c,e,tp,lvrk)
	if c:GetLevel()<=lvrk then return false end
	return (c:IsSetCard(0xcf) or c:IsSetCard(0x1048) or c:IsSetCard(0x1073)) and c:IsType(TYPE_MONSTER)
	 and ((c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:IsSetCard(0x10cf))
	 or (c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function c249000907.tfiltere(c,e,tp,code,lvrk)
	if c:GetOriginalCode()==6165656 and code~=48995978 then return false end
	if (c:GetRank()-1)~=lvrk then return false end
	return (c:IsSetCard(0xcf) or c:IsSetCard(0x1048) or c:IsSetCard(0x1073)) and c:IsType(TYPE_MONSTER)
	 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function c249000907.filter(c,e,tp)
	local lvrk
	local hasrank=false
	if c:GetRank() > 0 then lvrk=c:GetRank() hasrank=true else lvrk=c:GetLevel() end
	return lvrk > 0 and c:IsFaceup() and (c:IsSetCard(0xcf) or c:IsSetCard(0x48) or c:IsSetCard(0x1073)) and c:IsType(TYPE_MONSTER) and
		(hasrank and (Duel.IsExistingMatchingCard(c249000907.tfiltere,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode(),lvrk) and Duel.GetLocationCountFromEx(tp,tp,c)>0)
		or Duel.IsExistingMatchingCard(c249000907.tfilterm,tp,LOCATION_DECK,0,1,nil,e,tp,lvrk))
end
function c249000907.chkfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0xcf) or c:IsSetCard(0x1048) or c:IsSetCard(0x1073)) and (c:GetLevel() > 0 or c:GetRank() > 0)
end
function c249000907.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c249000907.chkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c249000907.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,c249000907.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if g:GetFirst():GetRank() > 0 then Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA) else Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK) end
end
function c249000907.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local lvrk
	local hasrank=false
	if tc:GetRank() > 0 then lvrk=tc:GetRank() hasrank=true else lvrk=tc:GetLevel() end
	if lvrk < 1 then return end
	if hasrank then		
		if Duel.GetLocationCountFromEx(tp,tp,tc)<=0 or not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
		if tc:IsFacedown() or tc:IsImmuneToEffect(e) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c249000907.tfiltere,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetCode(),lvrk)
		local sc=g:GetFirst()
		if sc then
			local mg=tc:GetOverlayGroup()
			if mg:GetCount()~=0 then
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(tc))
			Duel.Overlay(sc,Group.FromCards(tc))
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	else
		if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,c249000907.tfilterm,tp,LOCATION_DECK,0,1,1,nil,e,tp,lvrk)
			if sg:GetCount()>0 then
				Duel.BreakEffect()
				local sc=sg:GetFirst()
				if sc:IsSetCard(0x10cf) then Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP) else Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end
				sg:GetFirst():CompleteProcedure()
			end
		end
	end
end