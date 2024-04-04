--[[
Number 205: Lich-Lord Xe'enafae
Numero 205: Signore-Lich Xe'enafae
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),7,3,nil,nil,99)
	--You can only control 1 "Lich-Lord Xe'enafae".
	c:SetUniqueOnField(1,0,id)
	--[[During your Standby Phase, if you do not have "Lich-Lord's Phylactery" in your GY: Detach 2 materials from this card, or destroy it if it has less than 2 materials.
	If you destroyed this card by this effect, destroy all cards on the field, except "Zombie World", then both players draw cards until they have 7 in their hand.
	Other cards destroyed by this effect cannot activate their effects while they are in the location they were sent to after being destroyed.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(s.sdcon,nil,s.sdtg,s.sdop)
	c:RegisterEffect(e1)
	--[[If you have "Lich-Lord's Phylactery" in your GY, this card gains the following effects.
	● This card gains the original effects of all monsters attached to it as material, except "Number 205: Lich-Lord Xe'enafae".
	● During your turn, your opponent cannot activate the effects of Zombie monsters they control.]]
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_SINGLE)
	e1x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1x:SetCode(id)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetCondition(aux.PhylacteryCondition)
	e1x:SetLabel(id)
	c:RegisterEffect(e1x)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(aux.PhylacteryCondition)
	e2:SetOperation(s.adjustop)
	e2:SetLabel(id)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(aux.AND(aux.TurnPlayerCond(0),aux.PhylacteryCondition))
	e3:SetValue(s.actlim)
	e3:SetLabel(id)
	c:RegisterEffect(e3)
end
function s.disfieldeff(typ,code)
	return (typ==EFFECT_TYPE_FIELD and (code==EFFECT_DISABLE or code==EFFECT_CANNOT_DISABLE or code==EFFECT_FORBIDDEN or code==EFFECT_IMMUNE_EFFECT))
		or typ&EFFECT_TYPE_GRANT>0
end
function s.xmateffcon(cond)
	return	function(e,...)
				return e:GetHandler():IsHasEffect(id) and (not cond or cond(e,...))
			end
end
function s.xmateffcon_fix(c,cond)
	return	function(e,...)
				return e:GetHandler():IsHasEffect(id) and (not cond or cond(e,...)) and c:IsAttachedTo(e:GetHandler())
			end
end
function s.matfilter(c)
	return c:IsMonster() and not c:IsCode(id) and not c:HasFlagEffect(id)
end

function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup():Filter(s.matfilter,nil)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
		local eset=tc:GetEffects()
		for _,effect in ipairs(eset) do
			if effect:GetOwner()==tc then
				local changed=false
				local typ=effect:GetType()
				if effect:GetLabel()~=id and not effect:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) and typ&(EFFECT_TYPE_ACTIVATE|EFFECT_TYPE_XMATERIAL)==0 then
					local fixchk=true
					local range=effect:GetRange()
					local code=effect:GetCode()
					if s.disfieldeff(typ,code) or not (not range or range==0 or range&LOCATION_MZONE>0) then
						fixchk=false
						local ge=effect:Clone()
						ge:SetOwner(c)
						local cond=ge:GetCondition()
						ge:SetCondition(s.xmateffcon_fix(tc,cond))
						ge:SetReset(RESET_EVENT|RESETS_STANDARD_FACEDOWN)
						c:RegisterEffect(ge,true)
					end
					if fixchk then
						changed=true
						typ=(typ&(~EFFECT_TYPE_SINGLE))|EFFECT_TYPE_XMATERIAL
					end
				end
				if changed then
					local ge=effect:Clone()
					ge:SetType(typ)
					local cond=effect:GetCondition()
					ge:SetCondition(s.xmateffcon(cond))
					ge:SetReset(RESET_EVENT|RESETS_STANDARD_FACEDOWN)
					tc:RegisterEffect(ge,true)
				end
			end
		end
	end
end

--E1
function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and not aux.PhylacteryCheck(tp)
end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	if c:GetOverlayCount()<2 then
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		g:AddCard(c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,PLAYER_ALL,LOCATION_ONFIELD)
		local ct1,ct2=7-Duel.GetHandCount(tp),7-Duel.GetHandCount(1-tp)
		if ct1>0 then
			Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct1)
		end
		if ct2>0 then
			Duel.SetAdditionalOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ct2)
		end
	end
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local ct=c:GetOverlayCount()
	if ct>=2 and c:CheckRemoveOverlayCard(tp,2,REASON_EFFECT) then
		c:RemoveOverlayCard(tp,2,2,REASON_EFFECT)
	elseif ct<2 and Duel.Destroy(c,REASON_EFFECT)>0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup()
			for tc in aux.Next(og) do
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_CANNOT_TRIGGER)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1,true)
			end
			local breakchk=false
			local turnp=Duel.GetTurnPlayer()
			for p=turnp,1-turnp,1-2*turnp do
				local ct=7-Duel.GetHandCount(p)
				if ct>0 then
					if not breakchk then
						Duel.BreakEffect()
						breakchk=true
					end
					Duel.Draw(p,ct,REASON_EFFECT)
				end
			end
		end
	end
end

--E3
function s.actlim(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE and re:GetHandler():IsControler(1-e:GetHandlerPlayer())
end