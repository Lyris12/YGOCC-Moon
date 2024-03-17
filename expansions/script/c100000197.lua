--[[
Kakuren, The Hiding Predator
Kakuren, Il Predatore Nascosto
Card Author: ohmyhowswaggy
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,3,s.TLcon,{s.TLmat,true})
	c:EnableReviveLimit()
	--[[This card gains ATK equal to the ATK its material had on the field.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetLabel(0)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabelObject(e0)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--[[During the Main Phase (Quick Effect): You can target 1 monster your opponent controls with lower ATK than this card; banish it until the End Phase.
	If that monster returns to the field while you control "Kakuren, The Hiding Predator", negate that monster's effects, its ATK becomes 0, and 1 monster you control gains that lost ATK.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetRelevantTimings()
	e2:SetFunctions(aux.MainPhaseCond(),nil,s.rmtg,s.rmop)
	c:RegisterEffect(e2)
end
function s.TLcon(e,c,tp,sg)
	if not sg then return true end
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsAttackAbove,2000),tp,LOCATION_MZONE,0,nil) or (sg and sg:IsExists(s.matfilter,1,nil,tp))
end
function s.TLmat(c,e,mg,tl,tp)
	return (c:IsCode(id-1) and c:HasLevel() and c:GetLevel()==tl:GetFuture()-1)
		or (c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_BEAST) and c:HasAttack() and Duel.IsExists(false,s.compareatk,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()-1))
end
function s.compareatk(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
function s.matfilter(c,tp)
	return c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_BEAST) and c:HasAttack() and Duel.IsExists(false,s.compareatk,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()-1)
end

--E1
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	if not tc or not tc:HasAttack() or not tc:IsFaceup() then
		e:SetLabel(-1)
		return
	end
	e:SetLabel(tc:GetAttack())
end
function s.atkcon(e)
	return e:GetLabelObject():GetLabel()>0
end
function s.atkval(e)
	return e:GetLabelObject():GetLabel()
end

--E2
function s.rmfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsAbleToRemoveTemp()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) and c:HasAttack() and Duel.IsExists(true,s.rmfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()-1) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	local g=Duel.Select(HINTMSG_REMOVE,true,tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,c:GetAttack()-1)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local locpos=tc:IsFaceup() and POS_FACEUP or POS_FACEDOWN
		if Duel.Remove(tc,locpos,REASON_EFFECT|REASON_TEMPORARY)>0 and tc:IsBanished() and aux.BecauseOfThisEffect(e)(tc) then
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT,1,0,STRING_TEMPORARILY_BANISHED)
			local c=e:GetHandler()
			if not Duel.PlayerHasFlagEffect(tp,id) then
				Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_RETURN_TO_FIELD)
				e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE|PHASE_END)
				e1:SetReset(RESET_PHASE|PHASE_END,1)
				e1:SetLabel(Duel.GetTurnCount(),id,0)
				e1:SetCondition(s.TimingCondition(PHASE_END))
				e1:SetOperation(s.ReturnLabelObjectToFieldOp(id))
				Duel.RegisterEffect(e1,tp)
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_MOVE)
			e1:SetLabelObject(tc)
			e1:SetFunctions(s.retcon(e),nil,nil,s.retop)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.TimingCondition(phase)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local tct,id,eid=e:GetLabel()
				local g=Duel.Group(Card.HasFlagEffect,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,id)
				if not g or #g==0 then
					e:Reset()
					return false
				end
				local turnct = not p and Duel.GetTurnCount() or Duel.GetTurnCount(p)
				return Duel.GetCurrentPhase()==phase
			end
end
function s.ReturnLabelObjectToFieldOp(id)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local tct,id,eid=e:GetLabel()
				local g=Duel.Group(Card.HasFlagEffect,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,id)
				local sg=g:Filter(Card.HasFlagEffect,nil,id)
				local rg=Group.CreateGroup()
				local turnp=Duel.GetTurnPlayer()
				for p=turnp,1-turnp,1-2*turnp do
					local sg1=sg:Filter(Card.IsPreviousControler,nil,p)
					if #sg1>0 then
						local sgm=sg1:Filter(Card.IsPreviousLocation,nil,LOCATION_MZONE)
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
						local tg=sgm:Select(tp,1,1,nil)
						if #tg>0 then
							rg:Merge(tg)
						end
					end
				end
				if #rg>0 then
					for tc in aux.Next(rg) do
						local og=e:GetOwner()
						local owner=tc:GetReasonEffect():GetOwner()
						if owner~=og then
							e:SetOwner(owner)
						end
						Duel.ReturnToField(tc,tc:GetPreviousPosition(),0xff&(~EXTRA_MONSTER_ZONE))
						e:SetOwner(og)
					end
				end
			end
end
function s.retfilter(c,tc,e)
	local re=c:GetReasonEffect()
	if not c:IsReason(REASON_EFFECT) or not re then return end
	return c==tc and c:GetPreviousLocation()==LOCATION_REMOVED and c:IsOnField() and re==e and c:IsFaceup()
end
function s.retcon(eff)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local tc=e:GetLabelObject()
				if not tc or not tc:HasFlagEffect(id) then
					e:Reset()
					return false
				end
				return eg:IsExists(s.retfilter,1,nil,tc,eff) and Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,id),LOCATION_ONFIELD,0,1,nil)
			end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_CARD,0,id)
	Duel.Negate(tc,e,0,nil,nil,TYPE_MONSTER)
	if not Duel.IsExists(false,Card.IsCanChangeAttack,tp,LOCATION_MZONE,0,1,nil) then return end
	local eff,oatk,natk=tc:ChangeATK(0,true,{c,true})
	local diff=oatk-natk
	if not tc:IsImmuneToEffect(eff) and diff>0 then
		Duel.AdjustInstantly(tc)
		local g=Duel.Select(HINTMSG_ATKCHANGE,false,tp,Card.IsCanChangeAttack,tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			g:GetFirst():UpdateATK(diff,true,{c,true})
			Duel.AdjustInstantly(g:GetFirst())
		end
	end
end