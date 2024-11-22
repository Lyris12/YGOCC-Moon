--[[
Manaseal Word - Void
Parola Manasigillo - Vuoto
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--If you control a "Manaseal" monster, you can activate this card from your hand.
	c:TrapCanBeActivatedFromHand(s.handactcon,aux.Stringid(id,5))
	--[[Activate 1 of these effects.
	● Banish 1 Normal or Quick-Play Spell from either GY that meets its activation conditions; this effect becomes that Spell's activation effect, also, until the end of the next turn after this
	effect resolves, neither player can activate cards or effects with the same original name as that banished card.
	● Send 3 "Manaseal" monsters from your Deck to the GY; for the next 2 turns after this effect resolves, neither player can activate Spell Cards or effects in the GY, except "Rank-Up-Magic" or
	"Remnant" Spell Cards.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCost(aux.DummyCost)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--[[If you control "Manaseal Rune Weaving" while this card is in your GY, apply the following effect.
	● Each time the activation or effect of a Spell Card or effect is negated, all "Manaseal" monsters you currently control immediately gain 400 ATK/200 DEF.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,6)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_CHAIN_DISABLED)
	c:RegisterEffect(e3)
end
function s.handactcon(e)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_MANASEAL),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--E1
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_MANASEAL) and c:IsAbleToGraveAsCost()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.cfilter,tp,LOCATION_DECK,0,3,nil) end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.cfilter,tp,LOCATION_DECK,0,3,3,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.actfilter(c)
	return (c:IsNormalSpell() or c:IsSpell(TYPE_QUICKPLAY)) and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(false,true,false)~=nil
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	end
	local costchk=e:IsCostChecked()
	local b1=e:IsCostChecked() and Duel.IsExists(false,s.actfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	e:SetCostCheck(costchk)
	local b2=not e:IsCostChecked() or s.cost2(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	if opt==0 then
		e:SetProperty(0)
		local tc=Duel.Select(HINTMSG_REMOVE,false,tp,s.actfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil):GetFirst()
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
		local codes={tc:GetOriginalCodeRule()}
		local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
		Duel.ClearTargetCard()
		tc:CreateEffectRelation(e)
		local tg=te:GetTarget()
		e:SetProperty(te:GetProperty())
		if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
		e:SetCategory(0)
		te:SetLabelObject(e:GetLabelObject())
		e:SetLabelObject(te)
		Duel.ClearOperationInfo(0)
		e:SetOperation(s.activate(opt,codes))
	elseif opt==1 then
		e:SetCategory(0)
		e:SetProperty(0)
		if e:IsCostChecked() then
			s.cost2(e,tp,eg,ep,ev,re,r,rp,1)
		end
		e:SetOperation(s.activate(opt,nil))
	end
end
function s.activate(opt,codes)
	if opt==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					e,tp,eg,ep,ev,re,r,rp=aux.OperationRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
					local te=e:GetLabelObject()
					if te then
						local tc=te:GetHandler()
						e:SetLabelObject(te:GetLabelObject())
						local op=te:GetOperation()
						if op then op(e,tp,eg,ep,ev,re,r,rp) end
					end
					if type(codes)=="table" then
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_FIELD)
						e1:SetCode(EFFECT_CANNOT_ACTIVATE)
						e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
						e1:SetTargetRange(1,1)
						e1:SetLabel(table.unpack(codes))
						e1:SetValue(s.aclimit)
						e1:SetReset(RESET_PHASE|PHASE_END,2)
						Duel.RegisterEffect(e1,tp)
						Duel.RegisterHint(tp,id,PHASE_END,2,id,3)
						Duel.RegisterHint(1-tp,id,PHASE_END,2,id,3)
					end
					aux.EndRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
				end
	elseif opt==1 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local c=e:GetHandler()
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_FIELD)
					e1:SetCode(EFFECT_CANNOT_ACTIVATE)
					e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
					e1:SetTargetRange(1,1)
					e1:SetValue(s.aclimit2)
					e1:SetReset(RESET_PHASE|PHASE_END,2)
					Duel.RegisterEffect(e1,tp)
					Duel.RegisterHint(tp,id,PHASE_END,2,id,4)
					Duel.RegisterHint(1-tp,id,PHASE_END,2,id,4)
					aux.ManagePyroClockInteraction(c,tp,nil,PHASE_END,2,nil,nil,e1)
				end
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsOriginalCodeRule(e:GetLabel())
end
function s.aclimit2(e,re,tp)
	return re:IsActiveType(TYPE_SPELL) and re:GetActivateLocation()==LOCATION_GRAVE and not re:GetHandler():IsSetCard(ARCHE_REMNANT,ARCHE_RUM)
end

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING),tp,LOCATION_ONFIELD,0,1,nil)
		and re:IsActiveType(TYPE_SPELL)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(aux.FaceupFilter(Card.IsSetCard,ARCHE_MANASEAL),tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,tp,id)
	for tc in aux.Next(g) do
		tc:UpdateATKDEF(400,200,true,{c,true})
	end
end