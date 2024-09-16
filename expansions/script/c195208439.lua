--created by Seth, coded by Lyris
--Mextro Diatron
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.mfilter,3,3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.xfilter)
	if not s.global_check then
		s.global_check=true
		local mg,mc=Card.GetMutualLinkedGroup,Card.GetMutualLinkedGroupCount
		Card.GetMutualLinkedGroup=function(c)
			local g=mg(c)
			local ct=c:GetFlagEffectLabel(19520843)
			if ct and c:GetCardTargetCount()+1>=ct then
				g:Merge(Duel.GetMatchingGroup(s.lfilter,tp,LOCATION_MZONE,0,nil))
			end
			return g
		end
		Card.GetMutualLinkedGroupCount=function(c)
			return math.max(#mg(c),mc(c))
		end
		if not Mextro then Mextro={} end
		Mextro.MutualLinkFilter=Mextro.Mextro.MutualLinkFilter or function(c)
			local ct=c:GetFlagEffectLabel(19520843)
			return ct and c:GetCardTargetCount()+1>=ct
		end
	end
end
function s.mfilter(c)
	return c:GetMutualLinkedGroupCount()>0 and c:IsSetCard(0xee5)
end
function s.xfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_LINK)
end
function s.gchk(g,e,tp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,#g,e,tp)
end
function s.filter(c,lk,e,tp)
	return c:IsSetCard(0xee5) and c:IsLink(lk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.cost(e,tp,_,_,_,_,_,_,chk)
	local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil)
	if chk==0 then return g:CheckSubGroup(s.gchk,1,3,e,tp)
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)<1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	e:SetLabel(Duel.SendtoGrave(g:SelectSubGroup(tp,s.gchk,false,1,3),REASON_COST+REASON_DISCARD))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.slim)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.slim(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_LINK)
end
function s.target(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return e:IsCostChecked() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.operation(e,tp)
	local c=e:GetHandler()
	local lk=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,1,nil,lk,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		if c:IsRelateToEffect(e) then
			tc:RegisterFlagEffect(19520843,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,2,aux.Stringid(19520843,0))
			tc:SetCardTarget(c)
			c:RegisterEffect(19520843,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,2,aux.Stringid(19520843,0))
			c:SetCardTarget(tc)
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
