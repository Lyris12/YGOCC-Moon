--[[
Rank-Up-Magic - Ritual of Verdanse
Alza-Rango-Magico - Rituale di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANGEL_OF_VERDANSE)
	--[[This card can be used to Ritual Summon any "Verdanse" Ritual Monster from your hand. You must also Tribute monsters from your hand or field whose total Levels/Ranks
	equal or exceed the Level of the Ritual Monster you are Ritual Summoning. If you are Ritual Summoning "Angel of Verdanse" this way,
	you can also send 1 "Verdanse" monster from your Deck to the GY for the Ritual Summon of that monster.
	If you control an Xyz Summoned "Number" Xyz Monster, you can also use materials attached to Xyz Monsters on the field as Tributes.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetCustomCategory(CATEGORY_SPSUMMON_RITUAL_MONSTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If this card is in your GY: You can target 1 DARK "Number" Xyz Monster you control; place this card on the bottom of the Deck,
	and if you do, Special Summon, from your Extra Deck, 1 "Number C" Xyz Monster, with the same original number in its name as that target,
	by using that target as the material. (This is treated as Xyz Summon. Transfer its materials to that target.)]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetFunctions(
		nil,
		nil,
		s.xyztg,
		s.xyzop
	)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetCode(EFFECT_OVERLAY_RITUAL_MATERIAL)
		ge1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		ge1:SetCondition(function() return s.EnableExtraReleaseEffect end)
		ge1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_XYZ))
		Duel.RegisterEffect(ge1,0)
	end
end
function s.GetRitualSummonValue(c,rc)
	local n,typ=c:GetRatingAuto()
	if typ==0 then
		return c:GetRitualLevel(rc)
	elseif typ&(TYPE_XYZ)~=0 then
		return n
	end
end
function s.RitualCheckGreater(g,c,lv)
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(s.GetRitualSummonValue,lv,c)
end
function s.RitualCheck(g,tp,c,lv,exc)
	local mg=g:Clone()
	if exc then
		mg:AddCard(exc)
	end
	return s.RitualCheckGreater(g,c,lv) and Duel.GetMZoneCount(tp,mg,tp)>0 and (not c.mat_group_check or c.mat_group_check(g,tp))
		and (not aux.RCheckAdditional or aux.RCheckAdditional(tp,g,c))
end
function s.RitualCheckAdditionalLevel(c,rc)
	local n,typ=c:GetRatingAuto()
	if typ==0 then
		local raw_level=c:GetRitualLevel(rc)
		local lv1=raw_level&0xffff
		local lv2=raw_level>>16
		if lv2>0 then
			return math.min(lv1,lv2)
		else
			return lv1
		end
	elseif typ&(TYPE_XYZ)~=0 then
		return n
	end
end
function s.RitualCheckAdditional(c,lv)
	return	function(g,ec)
				if ec then
					return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g,ec)) and g:GetSum(s.RitualCheckAdditionalLevel,c)-s.RitualCheckAdditionalLevel(ec,c)<=lv
				else
					return not aux.RGCheckAdditional or aux.RGCheckAdditional(g)
				end
			end
end
function s.RitualUltimateFilter(c,e,tp,m1,exc)
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(ARCHE_VERDANSE) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c:IsCode(CARD_ANGEL_OF_VERDANSE) then
		local dg=Duel.Group(s.tgfilter,tp,LOCATION_DECK,0,nil)
		mg:Merge(dg)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=c:GetLevel()
	aux.GCheckAdditional=s.RitualCheckAdditional(c,lv)
	local res=mg:CheckSubGroup(s.RitualCheck,1,lv,tp,c,lv,exc)
	aux.GCheckAdditional=nil
	return res
end
function s.validlv(c)
	return c:IsLevelAbove(1) or c:IsRankAbove(1)
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VERDANSE) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
function s.rcheck(tp,g,c)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.rgcheck(g,ec)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.extramatfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		s.EnableExtraReleaseEffect = Duel.IsExists(false,s.extramatfilter,tp,LOCATION_MZONE,0,1,nil)
		local mg=Duel.GetRitualMaterialEx(tp):Filter(s.validlv,nil)
		s.EnableExtraReleaseEffect = false
		
		aux.RCheckAdditional=s.rcheck
		aux.RGCheckAdditional=s.rgcheck
		local res=Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg)
		aux.RCheckAdditional=nil
		aux.RGCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetCustomOperationInfo(0,CATEGORY_SPSUMMON_RITUAL_MONSTER,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	::RitualUltimateSelectStart::
	s.EnableExtraReleaseEffect = Duel.IsExists(false,s.extramatfilter,tp,LOCATION_MZONE,0,1,nil)
	local mg=Duel.GetRitualMaterialEx(tp):Filter(s.validlv,nil)
	s.EnableExtraReleaseEffect = false
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	aux.RCheckAdditional=s.rcheck
	aux.RGCheckAdditional=s.rgcheck
	local tg=Duel.SelectMatchingCard(tp,s.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg)
	local tc=tg:GetFirst()
	local mat
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc:IsCode(CARD_ANGEL_OF_VERDANSE) then
			local dg=Duel.Group(s.tgfilter,tp,LOCATION_DECK,0,nil)
			mg:Merge(dg)
		end
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local lv=tc:GetLevel()
		aux.GCheckAdditional=s.RitualCheckAdditional(tc,lv)
		mat=mg:SelectSubGroup(tp,s.RitualCheck,true,1,lv,tp,tc,lv)
		aux.GCheckAdditional=nil
		if not mat then
			aux.RCheckAdditional=nil
			aux.RGCheckAdditional=nil
			goto RitualUltimateSelectStart
		end
		tc:SetMaterial(mat)
		local dmat=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
		if #dmat>0 then
			mat:Sub(dmat)
			Duel.SendtoGrave(dmat,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
		end
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	aux.RCheckAdditional=nil
	aux.RGCheckAdditional=nil
end

--E2
function s.matfilter(c,e,tp)
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and no
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,no)
end
function s.xyzfilter(c,e,tp,mc,no)
	return c:IsSetCard(ARCHE_NUMBER_C) and aux.GetXyzNumber(c)==no and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.matfilter(chkc,e,tp) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExists(true,s.matfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,nil,nil,SEQ_DECKBOTTOM)>0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_XYZ) and tc:IsSetCard(ARCHE_NUMBER) and tc:IsAttribute(ATTRIBUTE_DARK) and tc:IsControler(tp) and not tc:IsImmuneToEffect(e)
			and aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then
			local no=aux.GetXyzNumber(tc)
			if not no then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,no)
			local sc=g:GetFirst()
			if sc then
				sc:SetMaterial(Group.FromCards(tc))
				Duel.Attach(tc,sc,true)
				if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
					sc:CompleteProcedure()
				end
			end
		end
	end
end