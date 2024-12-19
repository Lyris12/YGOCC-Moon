--[[
Vacuous Spire
Pinnacolo Vacuo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id,CARD_VACUOUS_VASSAL,CARD_POWER_VACUUM_ZONE,CARD_VACUOUS_MONARCH)
	--[[During your Main Phase or your opponent's Battle Phase (Quick Effect): You can banish 1 "Vacuous Vassal" from your field or GY; Special Summon this card from your hand, and if you do, and it
	is currently your opponent's Battle Phase, end the Battle Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetRelevantTimings()
	e1:HOPT()
	e1:SetFunctions(
		aux.MainOrBattlePhaseCond(0,nil,1),
		aux.BanishCost(s.cfilter,LOCATION_ONFIELD|LOCATION_GRAVE,0,1),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If you control "Power Vacuum Zone": You can add 1 "Vacuous Monarch" from your Deck or GY to your hand, and if you do, Special Summon 1 "Vacuous Vassal" from your GY or banishment.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),LOCATION_ONFIELD,0,1),
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
	--[[Your opponent's monsters cannot target for attacks, and your opponent cannot target with card effects, any monsters you control, except "Vacuous Spire".]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(s.tglimit)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.tglimit)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
--E1
function s.cfilter(c,_,tp)
	return c:IsFaceupEx() and c:IsCode(CARD_VACUOUS_VASSAL) and Duel.GetMZoneCount(tp,c)>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsBattlePhase(1-tp) then
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
	end
end

--E2
function s.thfilter(c,e,tp)
	return c:IsCode(CARD_VACUOUS_MONARCH) and c:IsAbleToHand() and (not e or Duel.IsExists(false,s.spfilter,tp,LOCATION_GB,0,1,c,e,tp))
end
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(CARD_VACUOUS_VASSAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetMZoneCount(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GB)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.ForcedSelect(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SearchAndCheck(tc) and Duel.GetMZoneCount(tp)>0 then
		local sc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_GB,0,1,1,nil,e,tp):GetFirst()
		if sc then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--E4
function s.tglimit(e,c)
	return not c:IsCode(id)
end