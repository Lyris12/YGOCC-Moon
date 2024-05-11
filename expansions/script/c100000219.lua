--[[
Cherubim of Verdanse
Cherubino di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[When your opponent Special Summons a monster(s) from the Extra Deck (Quick Effect): You can discard this card; negate the effects of that monster(s),
	then you can Special Summon 1 Level 5 "Verdanse" Ritual Monster from your hand or Deck. (This is treated as a Ritual Summon.)]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DISABLE|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		s.discon,
		aux.DiscardSelfCost,
		s.distg,
		s.disop
	)
	c:RegisterEffect(e1)
	--[[If a DARK Xyz Monster(s) and/or "Verdanse" Ritual Monster(s) you control would be destroyed by battle or card effect, you can banish this card from your GY instead.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(aux.NegateMonsterFilter,1,nil) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,#eg,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.disfilter(c,e)
	return aux.NegateMonsterFilter(c) and c:IsCanBeDisabledByEffect(e)
end
function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(s.disfilter,nil,e)
	if #g>0 and Duel.Negate(g,e,0,false,false,TYPE_MONSTER)>0 and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
		local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
			local tc=sg:GetFirst()
			tc:SetMaterial(nil)
			Duel.BreakEffect()
			if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end

--E2
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and s.chkfilter(c)
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT|REASON_BATTLE)
end
function s.chkfilter(c)
	return (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)) or (c:IsSetCard(ARCHE_VERDANSE) and c:IsMonster(TYPE_RITUAL))
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
end