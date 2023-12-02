--[[
Monochrome Valkyrie RK2
Valchiria Monocroma RK2
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,2,2)
	--[[If a Spell Card is activated (except during the Damage Step): You can Special Summon 1 "Monochrome Valkyrie RK4" from your Extra Deck,
	by using this face-up card you control as material. (This is treated as an Xyz Summon. Transfer its materials to the Summoned monster.)]]
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1x:SetCode(EVENT_CHAIN_CREATED)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetFunctions(s.regcon1,nil,nil,s.regop1)
	c:RegisterEffect(e1x)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[If "Black and White Wave" is activated while this card is in your GY (except during the Damage Step):
	You can Special Summon this card, and if you do, attach 1 Level 2 or lower Synchro Monster from your Extra Deck or GY to it as material.]]
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2x:SetCode(EVENT_CHAIN_CREATED)
	e2x:SetRange(LOCATION_GRAVE)
	e2x:SetFunctions(s.regcon2,nil,nil,s.regop2)
	c:RegisterEffect(e2x)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
--E1
function s.regcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsActiveType(TYPE_SPELL)
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,fid)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:HasFlagEffectLabel(id,c:GetFieldID())
end
function s.filter(c,e,tp,mc)
	return c:IsType(TYPE_XYZ) and c:IsCode(CARD_MONOCHROME_VALKYRIE_RK4)
		and mc:IsCanBeXyzMaterial(c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() and c:IsControler(tp) and not c:IsImmuneToEffect(e) and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local tc=g:GetFirst()
		if tc then
			tc:SetMaterial(Group.FromCards(c))
			Duel.Attach(c,tc)
			if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end

--E2
function s.regcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsCode(CARD_BLACK_AND_WHITE_WAVE)
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,fid)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:HasFlagEffectLabel(id+100,c:GetFieldID())
end
function s.xyzfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(2) and c:IsCanOverlay(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,tp)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.GetMZoneCount(tp)>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsType(TYPE_XYZ) then
		Duel.HintMessage(tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,aux.Necro(s.xyzfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,tp)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			if not tc:IsImmuneToEffect(e) then
				Duel.Attach(tc,c)
			end
		end
	end
end