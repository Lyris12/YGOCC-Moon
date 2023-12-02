--[[
Diabolical Quarphex LV4
Quarphex Diabolico LV4
Card Author: Xarc
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[Cannot be destroyed by battle.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--[[Once per turn (Quick Effect): You can target 1 monster your opponent controls; it becomes Level 4 until the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,nil,s.lvtg,s.lvop)
	c:RegisterEffect(e2)
	--[[Activate only as Chain Link 4 (Quick Effect): Ritual Summon 1 "Diabolical Quarphex LV8" from your hand or Deck by Tributing monsters
	from your hand or either field whose total Levels exactly equal 8, including this card.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_RELEASE|CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetFunctions(s.condition,nil,s.target,s.operation)
	c:RegisterEffect(e3)
end
s.lvup={CARD_DIABOLICAL_QUARPHEX_LV8}

--E2
function s.lvfilter(c)
	return c:IsFaceup() and c:HasLevel() and not c:IsLevel(4)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.lvfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
	end
end

--E3
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ev==3
end
function s.filter(c)
	return c:IsCode(CARD_DIABOLICAL_QUARPHEX_LV8)
end
function s.oppomat(c,e,tp)
	return not c:IsImmuneToEffect(e) and c:IsFaceup() and c:IsReleasableByEffect() and c:HasLevel() and c:GetLevel()>0
end
function s.fixedlv()
	return 8
end
function s.rcheck(gc)
	return	function(tp,g,c)
				return g:IsContains(gc)
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local mg2=Duel.Group(s.oppomat,tp,0,LOCATION_MZONE,nil,e,tp)
		aux.RCheckAdditional=s.rcheck(c)
		local res=mg:IsContains(c) and Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,s.filter,e,tp,mg,mg2,s.fixedlv,"Equal")
		aux.RCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local c=e:GetHandler()
	local mg=Duel.GetRitualMaterial(tp)
	local mg2=Duel.Group(s.oppomat,tp,0,LOCATION_MZONE,nil,e,tp)
	if not c:IsRelateToChain() or (not mg:IsContains(c) and not mg2:IsContains(c)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	aux.RCheckAdditional=s.rcheck(c)
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,s.filter,e,tp,mg,mg2,s.fixedlv,"Equal")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg2=mg2:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
		mg:RemoveCard(tc)
		end
		if not mg:IsContains(c) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		Duel.SetSelectedCard(c)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,s.fixedlv(),"Equal")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,s.fixedlv(),tp,tc,s.fixedlv(),"Equal")
		aux.GCheckAdditional=nil
		if not mat then
			aux.RCheckAdditional=nil
			goto cancel
		end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	aux.RCheckAdditional=nil
end
