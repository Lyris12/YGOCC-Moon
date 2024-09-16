--[[
Dynastygian Salvage Drones - "Locust"
Droni di Recupero Dinastigiani - "Locuste"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
local FLAG_PENDING_SHUFFLE=id
function s.initial_effect(c)
	--[[During the Main Phase, when your opponent activates a Spell/Trap Card or effect, or the effect of a monster in their GY (Quick Effect):
	You can send this card from your hand or field to the GY; negate the activation, and if you do, banish that card face-down. During the next End Phase after this effect resolves,
	if that card is still banished face-down, shuffle it into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(
		s.discon,
		aux.ToGraveSelfCost,
		s.distg,
		s.disop
	)
	c:RegisterEffect(e1)
	--[[If this card is in your GY and you control a DARK "Number" Xyz Monster: You can banish this card from your GY, then target 1 card in your opponent's GY or banishment;
	attach it to 1 DARK "Number" Xyz Monster you control as material. This is a Quick Effect if you control "Dynastygian Listening Post".]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCustomCategory(CATEGORY_ATTACH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),
		aux.bfgcost,
		s.attg,
		s.atop
	)
	c:RegisterEffect(e2)
	local qecond=aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_DYNASTYGIAN_LISTENING_POST),LOCATION_ONFIELD,0,1)
	e2:QuickEffectClone(c,qecond,false,true)
end
--E1
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsMainPhase() or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	local trig_p,trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and (re:IsActiveType(TYPE_ST) or (re:IsActiveType(TYPE_MONSTER) and trig_p==1-tp and trig_loc==LOCATION_GRAVE))
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then
		return Duel.IsPlayerCanRemove(tp) and (not rc:IsRelateToChain(ev) or rc:IsAbleToRemove(tp,POS_FACEDOWN))
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local rc=re:GetHandler()
		if rc:IsRelateToChain(ev) and Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)>0 and rc:IsBanished(POS_FACEDOWN) then
			local eid=e:GetFieldID()
			local rct=Duel.GetNextPhaseCount(PHASE_END)
			local tct=rct==1 and -1 or Duel.GetTurnCount()
			rc:RegisterFlagEffect(FLAG_PENDING_SHUFFLE,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,rct,eid,aux.Stringid(id,1))
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(id,2)
			e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE|PHASE_END)
			e1:OPT()
			e1:SetLabel(eid,tct)
			e1:SetLabelObject(rc)
			e1:SetCondition(s.tdcon)
			e1:SetOperation(s.tdop)
			e1:SetReset(RESET_PHASE|PHASE_END,rct)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local eid,tct=e:GetLabel()
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(FLAG_PENDING_SHUFFLE,eid) then
		e:Reset()
		return false
	end
	return Duel.IsEndPhase() and Duel.GetTurnCount()~=tct
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_CARD,tp,id)
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	e:Reset()
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.atchfilter(c,e,tp)
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,c,c,e,tp)
end
function s.xyzfilter(c,mc,e,tp)
	return s.cfilter(c) and mc:IsCanBeAttachedTo(c,e,tp,REASON_EFFECT)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(1-tp) and s.atchfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExists(true,s.atchfilter,tp,0,LOCATION_GB,1,nil,e,tp) end
	local tc=Duel.Select(HINTMSG_ATTACH,true,tp,s.atchfilter,tp,0,LOCATION_GB,1,1,nil,e,tp):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
	end
	local g=Duel.Group(s.xyzfilter,tp,LOCATION_MZONE,0,tc,tc,e,tp)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,tc,1,0,0,g)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local xg=Duel.Select(HINTMSG_ATTACHTO,false,tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,tc,tc,e,tp)
		if #xg>0 then
			Duel.HintSelection(xg)
			Duel.Attach(tc,xg:GetFirst(),false,e,REASON_EFFECT,tp)
		end
	end
end