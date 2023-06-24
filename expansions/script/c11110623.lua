--Kjel Aesthetica, Lifeweaver's Pride
--Kjel Aesthetica, Orgoglio della Vitatessitrice
--Scripted by: XGlitchy30

xpcall(function() require("expansions/script/glitchylib_kjel_aesthetica") end,function() require("script/glitchylib_kjel_aesthetica") end)

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,4,s.TLcon,s.TLmaterial)
	c:EnableReviveLimit()
	--[[If this card is Time Leap Summoned, or Special Summoned by the effect of a "Lifeweaver" card: You can activate this effect;
	during the next Standby Phase, shuffle up to 3 of your "Lifeweaver" cards that are banished, and/or in your GY, into your Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(s.prcon)
	e1:SetOperation(s.prop)
	c:RegisterEffect(e1)
	--[[During the Main or Battle Phase (Quick Effect): You can target 1 "Lifeweaver" Normal Spell/Trap in your GY;
	return this card to your Extra Deck, then shuffle that target into your Deck, and if you do, apply its effect when that card is activated.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetCondition(aux.MainOrBattlePhaseCond())
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	if not aux.LifeweaverTriggeringSetcodeCheck then
		aux.LifeweaverTriggeringSetcodeCheck=true
		aux.LifeweaverTriggeringSetcode={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) then
		if rc:IsSetCard(ARCHE_LIFEWEAVER) then
			aux.LifeweaverTriggeringSetcode[cid]=true
			return
		end
	else
		if rc:IsPreviousSetCard(ARCHE_LIFEWEAVER) then
			aux.LifeweaverTriggeringSetcode[cid]=true
			return
		end
	end
	aux.LifeweaverTriggeringSetcode[cid]=false
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER)
end
function s.TLcon(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.TLmaterial(c)
	return c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_PSYCHIC)
end

--E1
function s.prcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP) then return true end
	if not re then return false end
	local rc=re:GetHandler()
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID)
		return aux.LifeweaverTriggeringSetcode[cid]==true
		
	elseif re:IsHasCustomCategory(nil,CATEGORY_FLAG_DELAYED_RESOLUTION) and re:IsHasCheatCode(CHEATCODE_SET_CHAIN_ID) then
		local cid=re:GetCheatCodeValue(CHEATCODE_SET_CHAIN_ID)
		return aux.LifeweaverTriggeringSetcode[cid]==true
		
	else
		return rc:IsSetCard(ARCHE_LIFEWEAVER)
	end
end
function s.prop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	local rct = Duel.IsStandbyPhase() and 2 or 1
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(2)
	e1:SetCustomCategory(0,CATEGORY_FLAG_DELAYED_RESOLUTION)
	e1:SetCheatCode(CHEATCODE_SET_CHAIN_ID,false,cid)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.rmcon)
	e1:SetOperation(s.rmop)
	e1:SetLabel(rct,Duel.GetTurnCount())
	e1:SetReset(RESET_PHASE|PHASE_STANDBY,rct)
	Duel.RegisterEffect(e1,tp)
end
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsAbleToDeck()
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local sp_label,turn=e:GetLabel()
	return (sp_label==1 or turn~=Duel.GetTurnCount()) and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,nil)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.Select(HINTMSG_TODECK,false,tp,aux.Necro(s.tdfilter),tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,3,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	e:Reset()
end

--FILTERS E2
function s.actfilter(c,h)
	if not (c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsNormalST() and c:IsAbleToDeck()) then return false end
	h:RegisterFlagEffect(APPLY_FLAG_LEAVES_MZONE,0,0,1)
	local res=(c:CheckActivateEffect(false,true,false)~=nil)
	h:ResetFlagEffect(APPLY_FLAG_LEAVES_MZONE)
	return res
end
--E2
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsInGY() and chkc:IsControler(tp) and s.actfilter(chkc) end
	if chk==0 then return c:IsAbleToExtra() and Duel.IsExistingTarget(s.actfilter,tp,LOCATION_GRAVE,0,1,nil,c) end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.actfilter,tp,LOCATION_GRAVE,0,1,1,nil,c)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,LOCATION_MZONE|LOCATION_GRAVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA) then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and tc:IsSetCard(ARCHE_LIFEWEAVER) and tc:IsNormalST() and tc:IsAbleToDeck() then
			Duel.BreakEffect()
			if Duel.ShuffleIntoDeck(tc)>0 then
				local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
				if not te then return end
				local tg=te:GetTarget()
				local op=te:GetOperation()
				if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
				Duel.BreakEffect()
				tc:CreateEffectRelation(te)
				Duel.BreakEffect()
				local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				for etc in aux.Next(g) do
					etc:CreateEffectRelation(te)
				end
				if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
				tc:ReleaseEffectRelation(te)
				for etc in aux.Next(g) do
					etc:ReleaseEffectRelation(te)
				end
			end
		end
	end
end