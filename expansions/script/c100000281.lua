--[[
Spellbook of the First
Libro di Magia del Fondatore
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Tribute 1 Spellcaster monster; Special Summon 1 "Magistus" monster with a different name from your Deck or GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(nil,aux.DummyCost,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY, then target 1 Spellcaster monster you control; equip it with 1 "Magistus" monster, except a Level 4 monster, from your Extra Deck, GY, or face-up field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(nil,aux.bfgcost,s.eqtg,s.eqop)
	c:RegisterEffect(e2)
end
--E1
function s.relfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,{c:GetCode()})
end
function s.spfilter(c,e,tp,codes)
	return c:IsMonster() and c:IsSetCard(ARCHE_MAGISTUS) and not c:IsCode(table.unpack(codes)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not e:IsCostChecked() then return false end
		return Duel.CheckReleaseGroup(tp,s.relfilter,1,nil,e,tp)
	end
	local rg=Duel.SelectReleaseGroup(tp,s.relfilter,1,1,nil,e,tp)
	local codes={rg:GetFirst():GetCode()}
	Duel.Release(rg,REASON_COST)
	e:SetLabel(table.unpack(codes))
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local codes={e:GetLabel()}
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,codes)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.eqtofilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and Duel.IsExists(false,s.eqfilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_EXTRA,0,1,c,c,e,tp)
end
function s.eqfilter(c,ec,e,tp)
	return c:IsMonster() and c:NotOnFieldOrFaceup() and c:IsSetCard(ARCHE_MAGISTUS) and not c:IsLevel(4) and ec:IsCanBeEquippedWith(c,e,tp,REASON_EFFECT)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqtofilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExists(true,s.eqtofilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.eqtofilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_EQUIP)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local g=Duel.Select(HINTMSG_EQUIP,false,tp,aux.Necro(s.eqfilter),tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,tc,tc,e,tp)
		if #g>0 then
			Duel.EquipToOtherCardAndRegisterLimit(e,tp,g:GetFirst(),tc)
		end
	end
end