--Ethereal Something
--Qualcosa di Etereo
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,Card.IsNeutral,Card.IsNegative,true)
	--Illusion effect
	aux.AddIllusionBattleEffect(c)
	--[[Cannot be Fusion Summoned, unless there is a Bigbang monster that is banished, on the field, or in either GY.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--[[If this card would be destroyed by an opponent's card effect, you can banish 1 Bigbang monster from either GY instead.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.reptg)
	c:RegisterEffect(e1)
	--[[During the End Phase: You can reveal 1 Bigbang monster from your Extra Deck, then banish monsters from your GY,
	whose combined total ATK and DEF equal or exceed the revealed monster's ATK and DEF, respectively; Special Summon the revealed monster, and if you do,
	it becomes an Illusion monster, and gains the following effect.
	● If this card battles, your opponent's monster cannot be destroyed by that battle.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:HOPT()
	e2:SetFunctions(nil,aux.DummyCost,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
--E0
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsMonster(TYPE_BIGBANG)
end
function s.splimit(e,se,sp,st,pos,tp)
	return st~=SUMMON_TYPE_FUSION or Duel.IsExistingMatchingCard(s.cfilter,0,LOCATION_MZONE|LOCATION_GB,LOCATION_MZONE|LOCATION_GB,1,nil)
end

--E1
function s.cfilter(c)
	return c:IsMonster(TYPE_BIGBANG) and c:IsAbleToRemoveAsCost()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:GetReasonPlayer()==1-tp and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
		return true
	else
		return false
	end
end

--E2
function s.spfilter(c,e,tp,exc)
	if not c:IsMonster(TYPE_BIGBANG) or (c:IsAttack(0) and c:IsDefense(0)) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local atk,def=c:GetAttack(),c:GetDefense()
	local g=Duel.Group(s.rmfilter,tp,LOCATION_GRAVE,0,exc)
	aux.GCheckAdditional=s.stop(atk,def)
	local res=g:CheckSubGroup(s.fgoal,1,#g,c,tp,atk,def,exc)
	aux.GCheckAdditional=nil
	return res
end
function s.rmfilter(c)
	return c:IsMonster() and c:HasAttack() and c:HasDefense() and (c:GetAttack()>0 or c:GetDefense()>0) and c:IsAbleToRemoveAsCost()
end
function s.stop(atk,def)
	return	function(g,c)
				if not c then return true end
				return g:GetSum(aux.GetCappedAttack)-aux.GetCappedAttack(c)<=atk or g:GetSum(aux.GetCappedDefense)-aux.GetCappedDefense(c)<=def
			end
end
function s.fgoal(g,c,tp,atk,def,exc)
	local exg=g:Clone()
	if exc then exg:AddCard(exc) end
	if Duel.GetLocationCountFromEx(tp,tp,exg,c)<=0 then
		return false
	end
	if g:IsExists(s.superfilter,1,nil,atk,def) then
		return #g==1
	end
	local sumatk=g:GetSum(aux.GetCappedAttack)
	local sumdef=g:GetSum(aux.GetCappedDefense)
	if sumatk>=atk and sumdef>=def then
		for tc in aux.Next(g) do
			if s.excessfilter(tc,sumatk,sumdef,atk,def) then
				return false
			end
		end
		return true
	end
	return false
end
function s.superfilter(c,atk,def)
	return c:GetAttack()>=atk and c:GetDefense()>=def
end
function s.excessfilter(c,sumatk,sumdef,atk,def)
	return sumatk-aux.GetCappedAttack(c)>=atk and sumdef-aux.GetCappedDefense(c)>=def
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExists(false,s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
	end
	::cancel::
	local g1=Duel.Select(HINTMSG_CONFIRM,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g1:GetFirst()
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		local atk,def=tc:GetAttack(),tc:GetDefense()
		local mg=Duel.Group(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		aux.GCheckAdditional=s.stop(atk,def)
		local g2=mg:SelectSubGroup(tp,s.fgoal,false,1,#mg,tc,tp,atk,def,nil)
		aux.GCheckAdditional=nil
		if not g2 then goto cancel end
		if #g2>0 then
			Duel.Remove(g2,POS_FACEUP,REASON_COST)
		end
		Duel.SetTargetCard(tc)
		Duel.SetCardOperationInfo(g1,CATEGORY_SPECIAL_SUMMON)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ILLUSION)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetTarget(s.indesval)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
function s.indesval(e,c)
	local h=e:GetHandler()
	return c==h:GetBattleTarget()
end