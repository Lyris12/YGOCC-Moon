--Black Luster Soldier - Xyz Paladin
function c249000358.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),10,3,c249000358.ovfilter,aux.Stringid(51543904,0),3,c249000358.xyzop)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,249000358)
	--attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(93)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c249000358.target2)
	e2:SetOperation(c249000358.operation2)
	c:RegisterEffect(e2)
	--special summon xyz
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31786629,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c249000358.target)
	e2:SetOperation(c249000358.operation)
	c:RegisterEffect(e2)
end
function c249000358.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
function c249000358.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10cf)
end
function c249000358.xyzop(e,tp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000358.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c249000358.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c249000358.filter3(c)
	return c:IsSetCard(0x10cf) or c:IsSetCard(0xbd)
end
function c249000358.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249000358.filter3),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
end
function c249000358.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249000358.filter3),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
    if g:GetCount()>0 then
    	Duel.Overlay(c,g)
    end
end
function c249000358.filter1(c,e,tp)
	local lv=c:GetLevel()
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and lv>=4
		and Duel.IsExistingMatchingCard(c249000358.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,lv,c:GetAttribute())
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
function c249000358.filter2(c,e,tp,mc,rk,att)
	return c:GetRank()-rk>=0 and c:GetRank()-rk<=2 and c:IsRace(RACE_WARRIOR) and c:IsAttribute(att) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function c249000358.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c249000358.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c249000358.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c249000358.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000358.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if (tc:IsFacedown() and not c:IsLocation(LOCATION_GRAVE)) or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000358.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetLevel(),tc:GetAttribute())
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
		if c:GetOverlayGroup():GetCount()>0 then
			Duel.BreakEffect()
			local g1=c:GetOverlayGroup()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(47660516,0))
			local mg2=g1:Select(tp,1,1,nil)
			local oc=mg2:GetFirst()
			Duel.Overlay(sc,mg2)
			Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		end
		sc:CompleteProcedure()
	end
end