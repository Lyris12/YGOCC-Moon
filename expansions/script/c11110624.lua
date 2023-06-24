--Veia Quartis, Lifeweaver's Determination
--Veia Quartis, Determinazione della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,4,s.TLcon,s.TLmaterial)
	c:EnableReviveLimit()
	--[[If this card is Time Leap Summoned, or Special Summoned by the effect of a "Lifeweaver" card: You can activate this effect;
	Special Summon 1 of your banished "Lifeweaver" monsters during the next Standby Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(s.prcon)
	e1:SetOperation(s.prop)
	c:RegisterEffect(e1)
	--[[During the Main or Battle Phase (Quick Effect): You can target 1 monster your opponent controls; return this card to your Extra Deck, and if you do,
	inflict damage to your opponent equal to half of that target's ATK.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DAMAGE)
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
	return c:IsAttributeRace(ATTRIBUTE_FIRE,RACE_PSYCHIC)
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
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local sp_label,turn=e:GetLabel()
	return (sp_label==1 or turn~=Duel.GetTurnCount()) and Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	e:Reset()
end

--E2
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return c:IsAbleToExtra() and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.Select(HINTMSG_FACEUP,true,tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(g:GetFirst():GetAttack()/2))
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA) then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsControler(1-tp) then
			local val=math.floor(tc:GetAttack()/2)
			Duel.Damage(1-tp,val,REASON_EFFECT)
		end
	end
end