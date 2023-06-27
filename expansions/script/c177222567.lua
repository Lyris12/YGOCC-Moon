--Oniritron Orb Devices Duplication
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 "Oniritron Device" card from your GY, and if you do, Set 2 "Oniritron Device" Spells/Traps directly from your Deck.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--If this card is in your GY: You can target 1 "Oniritron" Xyz Monster you control; attach this card to it as material.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.atchtg)
	e2:SetOperation(s.atchop)
	c:RegisterEffect(e2)
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsSetCard(0x1721)
end
function s.setfilter(c)
	return c:IsSSetable() and c:IsSetCard(0x1721) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local z=2
	if c:GetLocation()==LOCATION_SZONE then z=z-1 end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>z
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,2,nil)
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_GRAVE,0,1,1,c)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,2,nil) then
		local g2=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,2,2,nil)
		if #g2>0 then
			Duel.SSet(tp,g2)
			local fid=e:GetHandler():GetFieldID()
			local tc=g2:GetFirst()
			while tc do
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
				tc=g2:GetNext()
			end
			g2:KeepAlive()
			--But you cannot activate them this turn.
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetLabelObject(g2)
			e1:SetLabel(fid)
			e1:SetValue(s.aclimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.filter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e) and c:IsSetCard(0x721) and c:IsType(TYPE_XYZ)
end
function s.atchtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.atchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
	end
end
function s.actfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.aclimit(e,re,tp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.actfilter,nil,e:GetLabel())
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and tg:IsContains(re:GetHandler())
end