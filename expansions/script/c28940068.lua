--Aquatic Elemerge, Laurelei
Duel.LoadScript("Elemerge.lua")
local ref,id=GetID()
function ref.initial_effect(c)
	aux.AddFusionProcFun2(c,ref.rcmatfilter,ref.attmatfilter,true)
	--OnSummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(ref.hdtg)
	e1:SetOperation(ref.hdop)
	c:RegisterEffect(e1)
	
end
function ref.rcmatfilter(c) return c:IsRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT) end
function ref.attmatfilter(c) return c:IsFusionAttribute(ATTRIBUTE_WATER) end

function ref.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
	local val=Elemerge.GetAttributeCount(ATTRIBUTE_WATER,1)
	if val>=1 then Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK) end
end
function ref.hdop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	Duel.ConfirmCards(tp,hg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local sg=hg:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		Duel.ShuffleHand(1-tp)
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(ref.retcon)
		e1:SetOperation(ref.retop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		Elemerge.SummonLock(e)
		local val=Elemerge.GetAttributeCount(ATTRIBUTE_WATER,1)
		if val>0 then
			Duel.DisableShuffleCheck()
			local g=Duel.GetDecktopGroup(tp,val)
			Duel.ConfirmCards(tp,g)
			local gg=g:Filter(Card.IsAbleToGrave,nil):Select(tp,1,1,nil)
			if #gg>0 then Duel.SendtoGrave(gg,REASON_EFFECT) val=val-1 end
			Duel.SortDecktop(tp,tp,val)
		end
	end
end
function ref.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
function ref.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
