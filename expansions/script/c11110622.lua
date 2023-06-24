--Avir Saeisha, Lifeweaver's Satisfaction
--Avir Saeisha, Soddisfazione della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,4,s.TLcon,s.TLmaterial)
	c:EnableReviveLimit()
	--[[If this card is Time Leap Summoned, or Special Summoned by the effect of a "Lifeweaver" card: You can activate this effect;
	add 1 "Lifeweaver" card from your Deck or GY to your hand during the next Standby Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(s.prcon)
	e1:SetOperation(s.prop)
	c:RegisterEffect(e1)
	--[[When your opponent activates a Spell/Trap Card or effect (Quick Effect): You can return this card to your Extra Deck, and if you do,
	negate that effect, and if you do that, banish that card.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DISABLE|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
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
	return c:IsAttributeRace(ATTRIBUTE_WATER,RACE_PSYCHIC)
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
function s.thfilter(c)
	return c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsAbleToHand()
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local sp_label,turn=e:GetLabel()
	return (sp_label==1 or turn~=Duel.GetTurnCount()) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
	e:Reset()
end

--E2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_ST) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtra() and aux.nbcon2(tp,ev,re) end
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	aux.dbtg2(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA) and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Banish(eg)
	end
end