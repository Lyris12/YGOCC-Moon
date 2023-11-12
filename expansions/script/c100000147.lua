--[[
Space Valkyr - Astral Savior
Valkyr Spaziale - Salvatrice Astrale
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--bigbang
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.IsPositive,1,1,Card.IsNonNeutral,1)
	c:EnableReviveLimit()
	--[[For this card's Bigbang Summon, you can treat the ATK of 1 "Space Valkyr" as double its original ATK.]]
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_MATERIAL_CUSTOM_BIGBANG_STATS)
	e0:SetLabel(1)
	e0:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_SPACE_VALKYR))
	e0:SetValue(s.bbval)
	c:RegisterEffect(e0)
	--[[This card's ATK becomes 3300 while face-up on the field.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(3300)
	c:RegisterEffect(e1)
	--[[If this card is Bigbang Summoned by using a Bigbang Monster as material: You can add 1 "Bigbang" card from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(aux.BigbangSummonedCond,nil,s.thtg,s.thop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetLabelObject(e2)
	e3:SetValue(s.matcheck)
	c:RegisterEffect(e3)
	--[[When your opponent activates a card or effect (Quick Effect): You can banish 1 "Bigbang" card, or 1 Bigbang Monster, from your GY;
	negate that effect, and if you do, destroy that card, and if you do that, negate the activated effects and effects on the field of cards with the same original name as the destroyed card,
	until the end of this turn.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_DISABLE|CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetFunctions(s.discon,s.discost,s.distg,s.disop)
	c:RegisterEffect(e4)
end
--E0
function s.bbval(e,c,bc,mg)
	return c:GetBaseAttack()*2, nil
end

--E2
function s.thfilter(c)
	return c:IsSetCard(ARCHE_BIGBANG) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end
--E3
function s.matcheck(e,c)
	local obj=e:GetLabelObject()
	if c:GetMaterial():IsExists(Card.IsMonster,1,nil,TYPE_BIGBANG) then
		obj:SetLabel(1)
	else
		obj:SetLabel(0)
	end
end

--E4
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainDisablable(ev)
end
function s.cfilter(c)
	return (c:IsSetCard(ARCHE_BIGBANG) or c:IsMonster(TYPE_BIGBANG)) and c:IsAbleToRemoveAsCost()
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		local code1,code2=eg:GetFirst():GetOriginalCodeRule()
		if not code2 then code2=0 end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
		e1:SetTarget(s.distg2)
		e1:SetLabel(code1,code2)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(s.discon2)
		e2:SetOperation(s.disop2)
		e2:SetLabel(code1,code2)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetTarget(s.distg2)
		e3:SetLabel(code1,code2)
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.distg2(e,c)
	local code1,code2=e:GetLabel()
	return c:IsOriginalCodeRule(code1) or (code2~=0 and c:IsOriginalCodeRule(code2))
end
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	local code1,code2=e:GetLabel()
	return c:IsOriginalCodeRule(code1) or (code2~=0 and c:IsOriginalCodeRule(code2))
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.NegateEffect(ev)
end