--Rank-Up-Magic Mysterious Force
function c53313930.initial_effect(c)
	--Target 1 face-up "Mysterious" Xyz Monster you control; Special Summon from your Extra Deck, 1 "Mysterious" Xyz Monster with 1 Rank higher, by using it as the Xyz Material. (This Special Summon is treated as an Xyz Summon. Xyz Materials attached to it also become Xyz Materials on the Summoned monster.), also attach 1 of your banished monsters to that monster.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c53313930.target)
	e1:SetOperation(c53313930.activate)
	c:RegisterEffect(e1)
end
function c53313930.filter1(c,e,tp)
	local rk=c:GetRank()
	return rk>0 and c:IsFaceup() and c:IsSetCard(0xcf6)
		and Duel.IsExistingMatchingCard(c53313930.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
		and Duel.GetLocationCountFromEx(tp,tp,c)>0 and c:IsType(TYPE_XYZ)
end
function c53313930.filter2(c,e,tp,mc,rk)
	return c:GetRank()==rk and c:IsSetCard(0xcf6) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function c53313930.filter3(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function c53313930.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c53313930.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c53313930.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(c53313930.filter3,tp,LOCATION_REMOVED,0,1,nil) end
	e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c53313930.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c53313930.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCountFromEx(tp,tp,tc)<=0 then return end
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c53313930.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
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
		local sg=Duel.SelectMatchingCard(tp,c53313930.filter3,tp,LOCATION_REMOVED,0,1,1,nil)
		if sg:GetCount()>0 then
			Duel.Overlay(sc,sg)
		end
	end
end
