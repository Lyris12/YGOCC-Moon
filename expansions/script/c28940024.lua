--Aurogeois, Deptheaven's Decree
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
Duel.LoadScript("GLShortcuts.lua")
function ref.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	Deptheaven.AddXyzRevive(c,aux.TRUE,Deptheaven.Is)
	--Protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(ref.immcon)
	e1:SetOperation(ref.immop)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id)==0 end)
	e2:SetCost(ref.thcost)
	e2:SetTarget(ref.thtg)
	e2:SetOperation(ref.thop)
	c:RegisterEffect(e2)
end

--Protection
function ref.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
function ref.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Glitchy.SingleEffectGiver(c,c,EFFECT_INDESTRUCTABLE_BATTLE,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	Glitchy.SingleEffectGiver(c,c,EFFECT_IMMUNE_EFFECT,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,ref.efilter)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,1,aux.Stringid(id,0))
end
function ref.efilter(e,re)
	local c=e:GetHandler()
	return c~=re:GetOwner() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end

--Search
function ref.ngfilter(c) return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) end
function ref.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local max=1
	if Duel.IsExistingMatchingCard(ref.ngfilter,tp,0,LOCATION_ONFIELD,1,nil) then max=2 end
	e:SetLabel(e:GetHandler():RemoveOverlayCard(tp,1,max,REASON_COST))
end
function ref.thfilter(c) return Deptheaven.Is(c) and c:IsAbleToHand() end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if e:GetLabel()==2 then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,Duel.GetMatchingGroup(ref.ngfilter,tp,0,LOCATION_ONFIELD,nil),1,0,0)
	end
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,g)
		if e:GetLabel()==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local ng=Duel.SelectMatchingCard(tp,ref.ngfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #ng>0 then
				local tc=ng:GetFirst()
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				Glitchy.SingleEffectGiver(e:GetHandler(),tc,EFFECT_DISABLE,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				Glitchy.SingleEffectGiver(e:GetHandler(),tc,EFFECT_DISABLE_EFFECT,RESET_TURN_SET+RESET_PHASE+PHASE_END)
				Duel.AdjustInstantly(tc)
			end
		end
	end
end
