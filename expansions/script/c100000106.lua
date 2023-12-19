--Aeonstrider Enforcer
--Vigilante Marciaeoni
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib_helper.lua")
Duel.LoadScript("glitchylib_aeonstride.lua")
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	c:Activation()
	--[[When this card is placed in your Pendulum Zone, place Chronus Counters on it equal to the current Turn Count +1.]]
	local p0=Effect.CreateEffect(c)
	p0:Desc(0)
	p0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	p0:SetCode(EVENT_MOVE)
	p0:SetFunctions(s.ctcon,nil,nil,s.ctop)
	c:RegisterEffect(p0)
	--[[You can remove 3 Chronus Counters from your field; banish 1 monster on the field until the next Battle Phase,
	then you can return this card to your hand, and if you do, move the Turn Count forwards by 1 turn]]
	local p1=Effect.CreateEffect(c)
	p1:Desc(1)
	p1:SetCategory(CATEGORY_REMOVE|CATEGORY_TOHAND)
	p1:SetType(EFFECT_TYPE_IGNITION)
	p1:SetRange(LOCATION_PZONE)
	p1:HOPT()
	p1:SetFunctions(nil,aux.RemoveCounterCost(COUNTER_CHRONUS,3),s.exctg,s.excop)
	c:RegisterEffect(p1)
	--[[If this card is Normal or Special Summoned: You can banish the top 3 cards of each player's Deck,
	and if you do, add any Pendulum Monster banished by this effect to their owner's Extra Deck, face-up.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[While this card is face-up in your Extra Deck: You can target 1 "Aeonstride" card in your Pendulum Zone;
	Special Summon it, then move the Turn Count forward by 1 turn, and if you do, either place this card in your Pendulum Zone or Special Summon it.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_EXTRA)
	e2:HOPT()
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
	--[[(Quick Effect): You can add this card from your hand or field to your Extra Deck, face-up; banish 2 or more "Aeonstride" monsters from your field or face-up Extra Deck,
	then Special Summon 1 Bigbang Monster from your Extra Deck whose ATK/DEF is less than or equal to the total ATK/DEF of those banished monsters. (This is treated as a Bigbang Summon).]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(4)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,s.syncost,s.syntg,s.synop)
	c:RegisterEffect(e2)
end
--P0
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_PZONE) and c:IsLocation(LOCATION_PZONE)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetTurnCount(nil,true)
	if ct>0 and c:IsCanAddCounter(COUNTER_CHRONUS,ct) then
		c:AddCounter(COUNTER_CHRONUS,ct)
	end
end

--P1
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.Group(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then
		return #g>0
	end
	local c=e:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,PLAYER_ALL,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,c,1,c:GetControler(),c:GetLocation())
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then 
		Duel.HintSelection(g)
		if Duel.BanishUntil(g,e,tp,POS_FACEUP,PHASE_BATTLE_START,id,1,true,c,REASON_EFFECT,true)>0 and c:IsRelateToChain() and c:IsAbleToHand()
		and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) and c:AskPlayer(tp,5) then
			Duel.BreakEffect()
			if Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and aux.PLChk(c,tp,LOCATION_HAND) then
				Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)
			end
		end
	end
end

--FE1
function s.rmfilter(c,tp)
	return c:IsFaceup() and c:IsBanished() and c:IsMonster(TYPE_PENDULUM) and c:IsAbleToExtra() and Duel.IsPlayerCanSendtoDeck(tp,c)
end
--E1
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g1,g2=Duel.GetDecktopGroup(tp,3),Duel.GetDecktopGroup(1-tp,3)
		g1:Merge(g2)
		return g1:FilterCount(Card.IsAbleToRemove,nil)==6 and Duel.IsPlayerCanSendtoDeck(tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,6,PLAYER_ALL,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g1,g2=Duel.GetDecktopGroup(tp,3),Duel.GetDecktopGroup(1-tp,3)
	g1:Merge(g2)
	if #g1==0 then return end
	Duel.DisableShuffleCheck()
	if Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(s.rmfilter,nil,tp)
		if #og>0 then
			Duel.SendtoExtraP(og,nil,REASON_EFFECT)
		end
	end
end

--FE2
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) then
		local c=e:GetHandler()
		Duel.BreakEffect()
		if Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)~=0 and c:IsRelateToChain() then
			local b1=(Duel.CheckPendulumZones(tp) and c:CheckUniqueOnField(tp) and not c:IsForbidden())
			local b2=(Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
			local opt=aux.Option(tp,false,false,{b1,STRING_PLACE_IN_PZONE},{b2,STRING_SPECIAL_SUMMON})
			if opt==0 then
				Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			elseif opt==1 then
				Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

--FE2
function s.synfilter(c,e,tp,exc)
	if not c:IsType(TYPE_BIGBANG) or (c:IsAttack(0) and c:IsDefense(0)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) then return false end
	local atk,def=c:GetAttack(),c:GetDefense()
	local g=Duel.Group(s.rmfilter,tp,LOCATION_MZONE|LOCATION_EXTRA,0,exc)
	aux.GCheckAdditional=s.stop(atk,def)
	local res=g:CheckSubGroup(s.fgoal,2,#g,c,tp,atk,def,exc)
	aux.GCheckAdditional=nil
	return res
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_AEONSTRIDE) and c:HasAttack() and c:HasDefense() and (c:GetAttack()>0 or c:GetDefense()>0) and c:IsAbleToRemove()
end
function s.stop(atk,def)
	return	function(g,c)
				if not c then return true end
				return #g<=2 or g:GetSum(aux.GetCappedAttack)-aux.GetCappedAttack(c)<=atk or g:GetSum(aux.GetCappedDefense)-aux.GetCappedDefense(c)<=def
			end
end
function s.fgoal(g,c,tp,atk,def,exc)
	local exg=g:Clone()
	if exc then exg:AddCard(exc) end
	if Duel.GetLocationCountFromEx(tp,tp,exg,c)<=0 then
		return false
	end
	if g:IsExists(s.superfilter,1,nil,atk,def) then
		return #g==2
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
--E2
function s.syncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsAbleToExtraFaceupAsCost(tp,tp) or not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_BIGBANG_MATERIAL) then return false end
		return Duel.IsExists(false,s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SendtoExtraP(c,nil,REASON_COST)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() or (aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_BIGBANG_MATERIAL) and Duel.IsExists(false,s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil))
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_MZONE|LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_BIGBANG_MATERIAL) then return end
	::cancel::
	local g1=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g1:GetFirst()
	if tc then
		local atk,def=tc:GetAttack(),tc:GetDefense()
		local mg=Duel.Group(s.rmfilter,tp,LOCATION_MZONE|LOCATION_EXTRA,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		aux.GCheckAdditional=s.stop(atk,def)
		local g2=mg:SelectSubGroup(tp,s.fgoal,false,2,#mg,tc,tp,atk,def,nil)
		aux.GCheckAdditional=nil
		if not g2 then goto cancel end
		if #g2>0 and Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)>0 then
			tc:SetMaterial(nil)
			Duel.BreakEffect()
			if Duel.SpecialSummonStep(tc,SUMMON_TYPE_BIGBANG,tp,tp,false,false,POS_FACEUP) then
				tc:CompleteProcedure()
			end
			Duel.SpecialSummonComplete()
		end
	end
end