--custom constant card name
CARD_MUSE = 33889884

--effect codes
EFFECT_MUSE_REPLACE = 33889884
--change cost of any "µ" monster and interaction with "Muse Stage µ"
--following parameters:
--minc: the amount of your discarding
--maxc: maximum of your discarding
--f - the function for "c" if the effect is "discard other cards" if none use nil
function Auxiliary.musefilter(c) 
	return c:IsAbleToRemove() and c:IsHasEffect(EFFECT_MUSE_REPLACE,tp) 
end
function Auxiliary.musecost(minc,maxc,string,f)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
				end
				local b1=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,maxc,f) 
				local b2=Duel.IsExistingMatchingCard(Auxiliary.musefilter,tp,LOCATION_GRAVE,0,1,nil,tp)
				if chk==0 then return b1 or b2 end
				if b2 and (not b1 or Duel.SelectYesNo(tp,string)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
					local rg=Duel.SelectMatchingCard(tp,Auxiliary.musefilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
					if rg:GetCount()>0 then
						local te=rg:GetFirst():IsHasEffect(EFFECT_MUSE_REPLACE,tp)
						te:UseCountLimit(tp)
						Duel.Remove(rg,POS_FACEUP,REASON_COST+REASON_REPLACE)
					end
				else
					local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,minc,maxc,f)
					if g:GetCount()>0 then
						Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
					end
				end
			end
end
--adding tashkent first effect to handle some of the effects
--including the cost replace of "Muse Stage µ" and "Pixie Dragon" for field spell
--following parameters:
--c: - card to grant this effect will work
--string1 ~ string2: strings in cdb
--id: - hard once per turn clause
--f: - the function for "c" if the effect is "discard other cards" if none use nil
function Auxiliary.TashkentProcedure(c,string1,id,string2,flag,f)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(string1)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Auxiliary.TashkentCost(string2,f))
	e1:SetTarget(Auxiliary.TashkentTarget())
	e1:SetOperation(Auxiliary.TashkentOperation(flag))
	c:RegisterEffect(e1)
end
function Auxiliary.TashkentCost(string2,f)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local b1=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,f) 
				local b2=Duel.IsExistingMatchingCard(Auxiliary.musefilter,tp,LOCATION_GRAVE,0,1,nil,tp)
				if chk==0 then return e:GetHandler():IsAbleToGrave() and b1 or b2 end
				if Duel.SendtoGrave(e:GetHandler(),REASON_COST)~=0 then
					if b2 and (not b1 or Duel.SelectYesNo(tp,string)) then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
						local rg=Duel.SelectMatchingCard(tp,Auxiliary.musefilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
						if rg:GetCount()>0 then
							local te=rg:GetFirst():IsHasEffect(EFFECT_MUSE_REPLACE,tp)
							te:UseCountLimit(tp)
							Duel.Remove(rg,POS_FACEUP,REASON_COST+REASON_REPLACE)
						end
					else
						local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,f)
						if g:GetCount()>0 then
							Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
						end
					end
				end
			end
end
function Auxiliary.TashkentTarget()
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(Auxiliary.PlayMuseFilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
				if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
			end
end
function Auxiliary.PlayMuseFilter(c,tp)
	return c:IsCode(CARD_MUSE) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function Auxiliary.TashkentOperation(flag)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
				if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,flag,RESET_CHAIN,0,1) end
				local g=Duel.SelectMatchingCard(tp,Auxiliary.PlayMuseFilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp)
				Duel.ResetFlagEffect(tp,flag)
				local tc=g:GetFirst()
				if tc then
					local te=tc:GetActivateEffect()
					if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,flag,RESET_CHAIN,0,1) end
					Duel.ResetFlagEffect(tp,flag)
					local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc then
						Duel.SendtoGrave(fc,REASON_RULE)
						Duel.BreakEffect()
					end
					Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
					te:UseCountLimit(tp,1,true)
					local tep=tc:GetControler()
					local cost=te:GetCost()
					if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
					Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
				end
			end
end
--handling the 2 option effect except the other operations and targets
--following parameters:
--stage1 ~ stage2: 2 parameters / functions to grant the effect of 2 buttons
--string1 ~ string2: aux.Stringid from cdb
--op1 ~ op2: is the operation between function and parameters of the effect
function Auxiliary.OceanOptionProcedure(stage1,string1,stage2,string2,op1,op2)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return stage1(e,tp,eg,ep,ev,re,r,rp,0) or stage2(e,tp,eg,ep,ev,re,r,rp,0) end
				local sel
				if stage1(e,tp,eg,ep,ev,re,r,rp,0) and stage2(e,tp,eg,ep,ev,re,r,rp,0) then
					sel=Duel.SelectOption(tp,string1,string2) 
				elseif stage1(e,tp,eg,ep,ev,re,r,rp,0) then
					sel=0
					Duel.Hint(HINT_OPSELECTED,1-tp,string1)
				else
					sel=1
					Duel.Hint(HINT_OPSELECTED,1-tp,string2)
				end
				if sel==0 then
					stage1(e,tp,eg,ep,ev,re,r,rp,1)
					op1(e,tp,eg,ep,ev,re,r,rp)
				else
					stage2(e,tp,eg,ep,ev,re,r,rp,1)
					op2(e,tp,eg,ep,ev,re,r,rp)
				end
			end
end
--replace discard function for muse
function Auxiliary.MuseReplaceGroup()
	local b1=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) 
	local b2=Duel.IsExistingMatchingCard(Auxiliary.musefilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	if b2 and (not b1 or Duel.SelectYesNo(tp,aux.Stringid(2242483,3))) then
		local rg=Duel.SelectMatchingCard(tp,Auxiliary.musefilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
		local te=rg:GetFirst():IsHasEffect(EFFECT_MUSE_REPLACE,tp)
		te:UseCountLimit(tp)
		Duel.Remove(rg,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
end