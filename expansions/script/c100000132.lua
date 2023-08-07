--MMS - Myriad Mirage Star
--MMS - Miriade Miraggio Stella
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: You can target 1 "MMS -", "Photon", or "Galaxy" monster in your GY; Special Summon it.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--LIGHT monsters you control gain 100 ATK for each LIGHT monster you control.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
	e2:SetValue(aux.ForEach(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_LIGHT),LOCATION_MZONE,0,nil,100))
	c:RegisterEffect(e2)
	--If your LP are lower than your opponent's: You can send this card to the GY, then target 1 "MMS - Sherlock Holmes" and 1 Level 8 "Galaxy-Eyes" Dragon monster in your GY; Special Summon them.
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:HOPT()
	e3:SetFunctions(s.spcon,aux.ToGraveSelfCost,s.sptg,s.spop)
	c:RegisterEffect(e3)
end
--E1
function s.filter(c,e,tp)
	return c:IsSetCard(ARCHE_MMS,ARCHE_PHOTON,ARCHE_GALAXY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return true end
	if not Duel.PlayerHasFlagEffect(tp,id) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.activate)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E3
function s.spfilter1(c,e,tp)
	return c:IsMonster() and c:IsCode(CARD_MMS_SHERLOCK_HOLMES) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(ARCHE_GALAXY_EYES) and c:IsRace(RACE_DRAGON) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.GetMZoneCount(tp)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectTarget(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,g1,e,tp)
	g1:Merge(g2)
	Duel.SetCardOperationInfo(g1,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
