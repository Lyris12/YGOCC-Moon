--[[
Invernal of the War Chest
Invernale dei Fondi per la Guerra
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	--[[During your Main Phase, if this card is in your GY because it was sent there this turn: You can target 1 DARK "Number" Xyz Monster you control;
	attach this card to that target as material, and if you do, that monster gains the following effect.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCustomCategory(CATEGORY_ATTACH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		s.atcon,
		nil,
		s.attg,
		s.atop
	)
	c:RegisterEffect(e1)
	--[[If this card is detached from an Xyz Monster to activate that monster's effect, and is now in your GY: You can banish this card; draw 2 cards, then send the top 2 cards
	of your Deck to the GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORY_DRAW|CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		s.drawcon,
		aux.bfgcost,
		s.drawtg,
		s.drawop
	)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regfilter(c,p)
	return c:IsSummonPlayer(p) and c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER_C) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsBattlePhase() then return end
	if not Duel.PlayerHasFlagEffect(0,id) then
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_BATTLE,0,1,0)
	end
	Duel.UpdateFlagEffectLabel(0,id,#eg)
end

--E1
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()
end
function s.atfilter(c,e,tp,h)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and h:IsCanBeAttachedTo(c,e,tp,REASON_EFFECT)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atfilter(chkc,e,tp,c) end
	if chk==0 then return Duel.IsExists(true,s.atfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c) end
	local g=Duel.Select(HINTMSG_ATTACHTO,true,tp,s.atfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,c)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,c,1,0,0,g,1)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and s.atfilter(tc,e,tp,c) and Duel.Attach(c,tc,false,e,tp,REASON_EFFECT) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,1)
		e1:SetCustomCategory(CATEGORY_ATTACH)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE|PHASE_BATTLE)
		e1:OPT()
		e1:SetRange(LOCATION_MZONE)
		e1:SetFunctions(s.atcon2,nil,s.attg2,s.atop2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		if tc:RegisterEffect(e1) then
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		end
	end
end
function s.atcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
function s.attg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.PlayerHasFlagEffect(0,id) then
		local c=e:GetHandler()
		local ct=Duel.GetFlagEffectLabel(0,id)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,ct,PLAYER_ALL,LOCATION_GRAVE,c,1)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,ct,tp,0)
	end
end
function s.atop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.PlayerHasFlagEffect(0,id) then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsType(TYPE_XYZ) then
		local g=Duel.Group(aux.Necro(Card.IsCanBeAttachedTo),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,c,e,tp,REASON_EFFECT)
		if #g>0 then
			local ct=math.min(#g,Duel.GetFlagEffectLabel(0,id))
			Duel.HintMessage(tp,HINTMSG_ATTACH)
			local sg=g:Select(tp,ct,ct,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.Attach(sg,c,false,e,tp,REASON_EFFECT)
			end
		end
	end
end

--E2
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local checkev,_eg=Duel.CheckEvent(EVENT_DETACH_MATERIAL,true)
	return checkev and c:IsPreviousLocation(LOCATION_OVERLAY) and c:IsReason(REASON_COST) and re and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and _eg:IsContains(re:GetHandler())
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
	end
end