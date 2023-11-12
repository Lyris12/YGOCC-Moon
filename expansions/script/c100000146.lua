--[[
Astrofrost Knight
Cavaliere Astrogelo
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--bigbang & pandemonium types
	aux.AddOrigPandemoniumType(c)
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.IsNeutral,1,1,Card.IsNonNeutral,1,1)
	c:EnableReviveLimit()
	--[[During the Main Phase: You can Set 1 "Bigbang" Spell/Trap from your Deck. It can be activated this turn.]]
	local p1=Effect.CreateEffect(c)
	p1:Desc(0)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetRange(LOCATION_SZONE)
	p1:HOPT()
	p1:SetRelevantTimings()
	p1:SetFunctions(nil,nil,s.settg,s.setop)
	c:RegisterEffect(p1)
	--[[If your opponent Special Summons a monster(s) from the Extra Deck: You can banish 1 "Bigbang" card, or 1 Bigbang monster, from your GY;
	Special Summon this card, and if you do, equip 1 of your opponent's monsters that was Special Summoned from the Extra Deck to this card.]]
	local p2=Effect.CreateEffect(c)
	p2:Desc(1)
	p2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_EQUIP)
	p2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	p2:SetProperty(EFFECT_FLAG_DELAY)
	p2:SetCode(EVENT_SPSUMMON_SUCCESS)
	p2:SetRange(LOCATION_SZONE)
	p2:SHOPT()
	p2:SetFunctions(s.spcon,s.spcost,s.sptg,s.spop)
	c:RegisterEffect(p2)
	Auxiliary.EnablePandemoniumAttribute(c,p1,p2,false,TYPE_EFFECT|TYPE_BIGBANG)
	--[[If this card is Bigbang Summoned: You can place it face-up in your Pandemonium Zone, but you cannot Pandemonium Summon for the rest of this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.BigbangSummonedCond,nil,s.pantg,s.panop)
	c:RegisterEffect(e1)
	--[[If this card is destroyed by a card effect: You can destroy 1 Positive and 1 Negative monster on the field;
	Special Summon 1 Neutral Bigbang Monster from your Extra Deck. (This is treated as a Bigbang Summon.)]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(4)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:HOPT()
	e2:SetFunctions(s.bbcon,s.bbcost,s.bbtg,s.bbop)
	c:RegisterEffect(e2)
end
--P1
function s.setfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_BIGBANG) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSetAndFastActivation(tp,g,e)
	end
end

--P2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSpecialSummoned,1,nil,LOCATION_EXTRA,1-tp)
end
function s.cfilter(c)
	return (c:IsSetCard(ARCHE_BIGBANG) or c:IsMonster(TYPE_BIGBANG)) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.eqfilter(c,tp)
	return c:IsSpecialSummoned(LOCATION_EXTRA) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.eqfilter,tp,0,LOCATION_MZONE,nil,tp)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if c:IsInBackrow() then
			ft=ft+1
		elseif e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsType(TYPE_FIELD) then
			ft=ft-1
		end
		return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ft>0 and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,tp,c)
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_EFFECT|TYPE_BIGBANG|TYPE_PANDEMONIUM,1000,1000,6,RACE_WARRIOR,ATTRIBUTE_WATER)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,1-tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,tp,c) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_EFFECT|TYPE_BIGBANG|TYPE_PANDEMONIUM,1000,1000,6,RACE_WARRIOR,ATTRIBUTE_WATER) then
		c:AddMonsterAttribute(c:GetOriginalPandemoniumType())
		if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			local g=Duel.Group(s.eqfilter,tp,0,LOCATION_MZONE,nil,tp)
			if #g>0 then
				Duel.HintMessage(tp,HINTMSG_EQUIP)
				local sg=g:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.HintSelection(g)
					Duel.EquipAndRegisterLimit(e,tp,sg:GetFirst(),c)
				end
			end
		end
	end
end

--E1
function s.pantg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsType(TYPE_PANDEMONIUM) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
	end
end
function s.panop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		aux.PandAct(c,tp,false,true)(e,tp,eg,ep,ev,re,r,rp)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return sumtype==SUMMON_TYPE_PANDEMONIUM
end

--E2
function s.bbcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT>0
end
function s.vbfilter(c)
	return c:IsFaceup() and (c:IsPositive() or c:IsNegative()) and not c:IsHasEffect(EFFECT_INDESTRUCTABLE)
end
function s.gcheck(g,e,tp)
	local tc1,tc2=g:GetFirst(),g:GetNext()
	return tc1:IsOppositeVibe(tc2) and Duel.IsExistingMatchingCard(s.bbfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
function s.bbfilter(c,e,tp,g)
	return c:IsMonster(TYPE_BIGBANG) and c:IsNeutral() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.bbcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.vbfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if chk==0 then
		return g:CheckSubGroup(s.gcheck,2,2,e,tp)
	end
	Duel.HintMessage(tp,HINTMSG_DESTROY)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,e,tp)
	if #sg==2 then
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_COST)
	end
end
function s.bbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_BIGBANG_MATERIAL) and (e:IsCostChecked() or Duel.IsExistingMatchingCard(s.bbfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.bbop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_BIGBANG_MATERIAL) then return end
	local g1=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.bbfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g1:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_BIGBANG,tp,tp,false,false,POS_FACEUP) then
			tc:CompleteProcedure()
		end
		Duel.SpecialSummonComplete()
	end
end