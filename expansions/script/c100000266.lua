--[[
Sceluspecter Tower Phantom
Scelleraspettro Spirito della Torre
Card Author: Walrus
Scripted by: XGlitchy30
]]

if not GLITCHYLIB_YGOCC_ARCHETYPES_LOADED then
	Duel.LoadScript("glitchylib_ygocc_archetypes.lua")
end

local s,id=GetID()
function s.initial_effect(c)
	--[[During the Main Phase (Quick Effect): You can shuffle 4 of your face-up banished cards with different names into the Deck;
	Special Summon this card from your hand or GY. You must control an Xyz Summoned "Number" Xyz Monster to activate and resolve this effect.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		s.spcon,
		s.spcost,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If this card is banished from the GY: You can target as many "Sceluspecter" monsters in your GY as possible with different original names from each other and this card;
	shuffle this card into the Deck, and if you do, banish those other targets.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(
		s.tdcon,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2)
	--[[If another monster you control attacks a Defense Position monster, and a card(s) was banished this turn, inflict double piercing battle damage to your opponent.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.pccon)
	e3:SetTarget(s.pctg)
	e3:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_REMOVE)
		ge:SetOperation(s.regop)
		Duel.RegisterEffect(ge,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
end

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsXyzSummoned()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(aux.Faceup(Card.IsAbleToDeck),tp,LOCATION_REMOVED,0,nil)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,4,4,aux.dncheck,0)
	end
	local tg=aux.SelectUnselectGroup(g,e,tp,4,4,aux.dncheck,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,0,1,nil) then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
function s.tdfilter(c,e)
	return c:IsMonster() and not c:IsOriginalCodeRule(id) and c:IsSetCard(ARCHE_SCELUSCEPTER) and c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
function s.tdfilterchk(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSCEPTER)
end
function s.gcheck(g,e,tp,mg,c)
	local res=g:GetClassCount(Card.GetOriginalCodeRule)==#g
	return res, not res
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.tdfilter(chkc) end
	local g=Duel.Group(s.tdfilter,tp,LOCATION_GRAVE,0,c,e)
	if chk==0 then
		return c:IsAbleToDeck() and #g>0
	end
	local ct=g:GetClassCount(Card.GetOriginalCodeRule)
	local tg=aux.SelectUnselectGroup(g,e,tp,ct,ct,s.gcheck,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetCardOperationInfo(tg,CATEGORY_REMOVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c)>0 then
		local g=Duel.GetTargetCards():Filter(s.tdfilterchk,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

--E3
function s.pccon(e)
	return Duel.PlayerHasFlagEffect(0,id)
end
function s.pctg(e,c)
	return c~=e:GetHandler()
end