--[[
Theurgist of Verdanse
Teurgo di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddCodeList(c,id,CARD_RUM_RITUAL_OF_VERDANSE)
	--[[If this card is Special Summoned: You can add 1 "Verdanse" Spell/Trap from your Deck or GY to your hand, then, if your opponent has 6 or more banished cards, draw 1 card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--[[During the Main Phase or Battle Phase, except during the Damage Step (Quick Effect): You can send this card from your hand or field to the GY;
	Ritual Summon 1 "Verdanse" Ritual Monster from your hand or GY, except "Theurgist of Verdanse", by Tributing DARK monsters from either field
	whose total Levels/Ranks/Link Ratings equal or exceed the Level of the Ritual Monster you are Ritual Summoning.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCustomCategory(CATEGORY_SPSUMMON_RITUAL_MONSTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		aux.MainOrBattlePhaseCond(),
		aux.DummyCost,
		s.rmtg,
		s.rmop)
	c:RegisterEffect(e2)
	--[[A DARK "Number" Xyz Monster that has this card as material gains this effect.
	● Your opponent cannot target this card with card effects, also it cannot be destroyed by your opponent's card effects.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.effcon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
		ge1:SetCode(EFFECT_EXTRA_RELEASE)
		ge1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		ge1:SetCondition(function() return s.EnableExtraReleaseEffect end)
		Duel.RegisterEffect(ge1,0)
	end
end
--E1
function s.thfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_VERDANSE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,ce)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g,tp) and Duel.GetBanishmentCount(1-tp)>=6 then
		if Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
		end
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

--E2
function s.GetRitualSummonValue(c,rc)
	local n,typ=c:GetRatingAuto()
	if typ==0 then
		return c:GetRitualLevel(rc)
	elseif typ&(TYPE_XYZ|TYPE_LINK)~=0 then
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
	elseif typ&(TYPE_XYZ|TYPE_LINK)~=0 then
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
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(ARCHE_VERDANSE) or c:IsCode(id) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
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
function s.mat_filter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and (c:IsControler(tp) or c:IsFaceup()) and (c:IsLevelAbove(1) or c:IsRankAbove(1) or c:IsLinkAbove(1))
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local exc=nil
		if e:IsCostChecked() then
			if not c:IsAbleToGraveAsCost() then return false end
			exc=c
		end
		s.EnableExtraReleaseEffect = true
		local mg=Duel.GetRitualMaterialEx(tp):Filter(s.mat_filter,exc,tp)
		s.EnableExtraReleaseEffect = false
		return Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp,mg,exc)
	end
	if e:IsCostChecked() then
		Duel.SendtoGrave(c,REASON_COST)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetCustomOperationInfo(0,CATEGORY_SPSUMMON_RITUAL_MONSTER,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	::RitualUltimateSelectStart::
	s.EnableExtraReleaseEffect = true
	local mg=Duel.GetRitualMaterialEx(tp):Filter(s.mat_filter,nil,tp)
	s.EnableExtraReleaseEffect = false
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.RitualUltimateFilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp,mg)
	local tc=tg:GetFirst()
	local mat
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
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
		if not mat then goto RitualUltimateSelectStart end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

--E3
function s.effcon(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end