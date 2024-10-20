--[[
Invernal of the War Forge
Invernale della Forgia di Guerra
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During your Main Phase, if you Xyz Summon a DARK "Number" Xyz Monster(s) using 3 or more materials: You can reveal this card in your hand; Special Summon this card,
	and if you do, add 2 "Invernal" monsters from your Deck to your hand with different original names, except "Invernal of the War Forge".]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		s.spcon,
		aux.RevealSelfCost(),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can add 1 Level 6 or lower DARK monster from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(
		nil,
		nil,
		xgl.SearchTarget(s.thfilter2),
		xgl.SearchOperation(s.thfilter2)
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[A DARK "Number" Xyz Monster that has this card as material gains this effect.
	● At the start of the Damage Step, if this card battles a monster that is unaffected by card effects (Quick Effect): Your opponent must send that monster to the GY,
	and if they do, they take 1000 damage.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(s.xmatcon)
	e3:SetTarget(s.xmattg)
	e3:SetOperation(s.xmatop)
	c:RegisterEffect(e3)
end

--E1
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:GetMaterialCount()>=3
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase(tp) and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_INVERNAL) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.SelectUnselectGroup(g,e,tp,2,2,aux.ogdncheckbrk,0)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Group(s.thfilter,tp,LOCATION_DECK,0,nil)
		if #g<2 then return end
		local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.ogdncheckbrk,1,tp,HINTMSG_ATOHAND)
		if #tg==2 then
			Duel.Search(tg)
		end
	end
end

--E2
function s.thfilter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelBelow(6)
end

--E3
function s.xmatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or not bc then return false end
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and bc:IsHasEffect(EFFECT_IMMUNE_EFFECT)
end
function s.xmattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,bc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end	
function s.xmatop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToBattle() and tc:IsRelateToChain() and Duel.SendtoGrave(tc,REASON_RULE,1-tp)>0 and tc:IsInGY() then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end