--Runath Alicath

local cid,id=GetID()

function cid.initial_effect(c)
	aux.AddLinkProcedure(c,cid.matfilter,2,2)
	c:EnableReviveLimit()
	Auxiliary.Add_Runeslots(c,2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cid.descond)
	e3:SetOperation(cid.desop)
	c:RegisterEffect(e3)
end

function cid.matfilter(c)
	return c:GetType(TYPE_MONSTER)
end

function cid.descond(e,tp,eg,ep,ev,re,r,rp)
	local any = 0x0ff5
	local red = 0x1ff5
	local blue = 0x2ff5
	local purple = 0x3ff5
	local yellow = 0x4ff5
	local orange = 0x5ff5
	local green = 0x6ff5
	local prismatic = 0x7ff5
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,any)
end

function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local g=Duel.SelectMatchingCard(tp,cm.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=g:Select(tp,1,1,nil)
		local tgc=tg:GetFirst()
		
		local red = 0
		local blue = 0
		local yellow = 0

		if tgc:IsSetCard(0x1ff5) or tgc:IsSetCard(0x5ff5) or tgc:IsSetCard(0x7ff5) then
			red = 1
		end 

		if tgc:IsSetCard(0x2ff5) or tgc:IsSetCard(0x3ff5) or tgc:IsSetCard(0x7ff5) then
			blue = 1
		end

		if tgc:IsSetCard(0x4ff5) or tgc:IsSetCard(0x6ff5) or tgc:IsSetCard(0x7ff5) then
			yellow = 1
		end

		Duel.SendtoGrave(tg,REASON_EFFECT)

		if red==1 then

			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
			g1:Merge(g2)
			Duel.SendtoGrave(g1,REASON_EFFECT)
		
		end

		if blue==1 then
			
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e:GetHandler():RegisterEffect(e1)

		end

		if yellow==1 then

			Duel.Draw(tp,1,REASON_EFFECT)
			Duel.BreakEffect()
			Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)

		end


	end


end

