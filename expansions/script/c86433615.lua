--Multitasktician SwitchXtrigger
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--link summon
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,cid.matfilter,1,1)
	--flip trigger
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0x:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0x:SetRange(LOCATION_MZONE)
	e0x:SetCode(EVENT_ADJUST)
	e0x:SetCondition(cid.flipcon)
	e0x:SetOperation(cid.flip)
	c:RegisterEffect(e0x)
	--shuffle
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,id)
	e0:SetCondition(cid.spcon)
	e0:SetTarget(cid.sptg)
	e0:SetOperation(cid.spop)
	c:RegisterEffect(e0)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
--cid.elist={}
--filters
function cid.counterfilter(c)
	return not c:IsType(TYPE_LINK) or not c:IsSetCard(0x86f)
end
function cid.matfilter(c)
	return c:IsLinkRace(RACE_CYBERSE)
end
function cid.spcheck(c)
	return c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function cid.flipfilter(c,lab)
	return c:IsFaceup() and c:IsType(TYPE_FLIP) and (not lab or c:GetFlagEffect(lab)<=0)
end
--protection
function cid.flipcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(cid.flipfilter,tp,LOCATION_MZONE,0,nil,false)>0
end
function cid.flip(e)
	local tp=e:GetHandlerPlayer()
	--if cid.elist[e:GetHandler()]==nil then cid.elist[e:GetHandler()]={} end
	local g=Duel.GetMatchingGroup(cid.flipfilter,tp,LOCATION_MZONE,0,nil,id+e:GetHandler():GetFieldID())
	if #g<=0 then return end
	local adj=false
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id+e:GetHandler():GetFieldID(),RESET_EVENT+RESETS_STANDARD,0,1)
		local egroup=global_card_effect_table[tc]
		if egroup~=nil then
			for i=1,#egroup do
				local ce=egroup[i]
				if ce and type(ce)=="userdata" and ce:IsHasType(EFFECT_TYPE_FLIP) then
					if not adj then adj=true end
					local cost=(type(ce:GetCost())=="function") and ce:GetCost() or false
					local e1=ce:Clone()
					e1:SetType(EFFECT_TYPE_IGNITION)
					e1:SetRange(LOCATION_MZONE)
					e1:SetLabel(e:GetHandler():GetFieldID())
					e1:SetLabelObject(tc)
					e1:SetCost(function(ef,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return (cost==false or cost(ef,tp,eg,ep,ev,re,r,rp,0)) end if cost~=false then cost(ef,tp,eg,ep,ev,re,r,rp,1) end Duel.RegisterFlagEffect(tp,id+ef:GetLabel(),0,0,1) end)
					--table.insert(cid.elist[e:GetHandler()],e1)
					--local el=cid.elist[e:GetHandler()][#cid.elist[e:GetHandler()]]
					local e2=Effect.CreateEffect(e:GetHandler())
					e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
					e2:SetLabel(e:GetHandler():GetFieldID())
					e2:SetRange(LOCATION_MZONE)
					e2:SetTargetRange(LOCATION_MZONE,0)
					e2:SetCondition(function(ef,tp) return Duel.GetFlagEffect(tp,id+ef:GetLabel())<=0 end)
					e2:SetTarget(function(ef,c) return c==ef:GetLabelObject():GetLabelObject() end)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					e2:SetLabelObject(e1)
					e:GetHandler():RegisterEffect(e2)
					local e3=Effect.CreateEffect(e:GetHandler())
					e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e3:SetLabel(e:GetHandler():GetFieldID())
					e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
					e3:SetRange(0xff)
					e3:SetCode(EVENT_ADJUST)
					e3:SetCondition(cid.resetcon)
					e3:SetOperation(cid.resetflag)
					e:GetHandler():RegisterEffect(e3)
				end
			end
		end
		tc=g:GetNext()
	end
	if adj then Duel.Readjust() end
end
function cid.resetcon(e)
	return (not e:GetHandler():IsLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)) or e:GetHandler():IsLocation(LOCATION_ONFIELD) and e:GetHandler():IsFacedown()
end
function cid.resetflag(e)
	if (not e:GetHandler():IsLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)) or e:GetHandler():IsLocation(LOCATION_ONFIELD) and e:GetHandler():IsFacedown() then
		if Duel.GetFlagEffect(e:GetHandlerPlayer(),id+e:GetLabel())>0 then
			Duel.ResetFlagEffect(e:GetHandlerPlayer(),id+e:GetLabel())
		end
		e:Reset()
	end
end
--alternative spsummon
function cid.thfilter(c)
	return (c:IsCode(86433597) or (c:IsType(TYPE_FLIP) and c:IsType(TYPE_MONSTER))) and c:IsAbleToHand()
end
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function cid.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabel()~=se:GetLabel() and c:IsType(TYPE_LINK) and c:IsSetCard(0x86f)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,3,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)>0 and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),TYPE_LINK)
		and Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end